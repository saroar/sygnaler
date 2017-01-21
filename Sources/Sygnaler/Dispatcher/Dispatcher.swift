import Vapor
import VaporAPNS

struct PusherCache {
    var sender: VaporAPNS
    var sandbox: Bool

    init(sender: VaporAPNS, sandbox: Bool) {
        self.sender = sender
        self.sandbox = sandbox
    }

    func send(_ message: ApplePushMessage, to device: String) -> Result {
        return self.sender.send(message, to: device)
    }
}

class Dispatcher {
    static let sharedInstance = Dispatcher()

    private(set) var isLoaded: Bool = false

    private var MAX_TRIES = 3

    private var certsDir: String?

    private var logger: LogProtocol?

    private var map: [String: PusherCache] = [:]

    private var `default`: PusherCache?

    private init() {
    }

    var totalInstances: Int {
        return self.map.count
    }

    public func loadPushersFromDB() throws {
        let pushers = try Pusher.all()

        for pusher in pushers {
            do {
                let _ = try self.append(pusher)
            } catch InitializeError.keyFileDoesNotExist {
                self.logger?.warning("[CONFIG] \(pusher.bundleId): \(InitializeError.keyFileDoesNotExist.description)")
            } catch InitializeError.certificateFileDoesNotExist {
                self.logger?.warning("[CONFIG] \(pusher.bundleId): \(InitializeError.certificateFileDoesNotExist.description)")
            } catch {
                self.logger?.error("\(error)")
            }
        }

        if self.totalInstances == 0 {
            self.logger?.warning("No pushers loaded.")
        } else {
            self.logger?.info("Loaded Pushers: \((self.getInstancesIds()).joined(separator: ", "))")
        }

        self.isLoaded = true
    }

    func set(maxTries tries: Int) {
        self.MAX_TRIES = tries
    }

    func set(logger log: LogProtocol) {
        self.logger = log
    }

    func set(certsDir dir: String) {
        self.certsDir = dir
    }

    func getInstancesIds() -> [String] {
        return Array(self.map.keys)
    }

    func getInstance(_ appId: String) -> PusherCache? {
        return self.map[appId]
    }

    func append(_ pusher: Pusher) throws -> PusherCache {
        let options = try buildOptions(pusher: pusher)
        let instance = try VaporAPNS(options: options)
        let sandbox = pusher.sandbox

        let p = PusherCache(sender: instance, sandbox: sandbox)

        self.map[pusher.bundleId.string!] = p

        return p
    }

    func send(notification: Notification) throws -> [String] {
        var rejected = [String]()
        var payload: Payload?
        let prio: ApplePushMessage.Priority = notification.priority == Priority.high ? .immediately : .energyEfficient

        for device in notification.devices {
            var tries = 0
            let appId = device.appId
            let pushKey = device.pushkey

            let instance: PusherCache

            if let pusherCache = self.getInstance(appId) {
                instance = pusherCache
            } else if let pusher = try Pusher.query().filter("enabled", true).filter("bundle_id", appId).first() {
                instance = try self.append(pusher)
            } else {
                rejected.append(pushKey)
                self.logger?.info("Got notification for unknown app ID \(appId)")
                continue
            }

            if payload == nil {
                payload = try self.buildPayload(notification: notification)
            }

            let pushMessage = ApplePushMessage(priority: prio, payload: payload!, sandbox: instance.sandbox)

            var shouldStop = false

            while tries < self.MAX_TRIES {
                let result = instance.send(pushMessage, to: pushKey)

                switch result {
                case let .success(messageId, deviceToken, serviceStatus):
                    self.logger?.warning("[SENDING] \(notification.id): \(serviceStatus)")
                    shouldStop = serviceStatus == .success

                case let .error(messageId, deviceToken, error):
                    self.logger?.warning("[SENDING] \(notification.id): \(error)")
                    switch error {
                    case .tooManyRequests, .idleTimeout, .shutdown, .internalServerError, .serviceUnavailable:
                        shouldStop = false
                    default:
                        rejected.append(pushKey)
                        shouldStop = true
                    }

                case let .networkError(error):
                    self.logger?.warning("[SENDING] \(notification.id): \(error)")
                    shouldStop = false
                }

                tries = tries + 1

                if shouldStop {
                    break
                }
            }

            if tries == self.MAX_TRIES {
                rejected.append(pushKey)
                self.logger?.info("[SENDING] \(notification.id): Max retries exceeded")
            }
        }

        return rejected
    }

    private func buildOptions(pusher: Pusher) throws -> Options {
        let appSufix = pusher.useVOIP ? ".voip" : ""
        let topic = "\(pusher.bundleId)\(appSufix)"

        return try Options(
                topic: topic,
                teamId: pusher.teamId,
                keyId: pusher.keyId,
                keyPath: "\(self.certsDir!)\(pusher.keyPath)"
        )
    }

    private func buildPayload(notification: Notification) throws -> Payload {
        let payload = Payload()
        let fromDisplay = self.getSenderName(notification)
        var locKey: String?
        var locArgs: [String]?

        payload.contentAvailable = true
        payload.extra["badge"] = self.getBadge(notification)

        if let roomId = notification.roomId {
            payload.extra["thread-id"] = roomId
        }

        switch notification.type {
        case "m.room.message", "m.room.encrypted":
            payload.extra["category"] = "MESSAGE"

            let roomDisplayName: String? = notification.roomName ?? notification.roomAlias
            var image, contentDisplay, actionDisplay: String?

            if let content = notification.content?.node, let messageType: String = content["msgtype"]?.string,
               let body: String = content["body"]?.string {
                switch messageType {
                case "m.image":
                    image = content["url"]?.string
                    payload.extra["image"] = image
                    contentDisplay = body

                case "m.text":
                    contentDisplay = body

                case "m.emote":
                    actionDisplay = body

                default:
                    contentDisplay = body
                }
            }

            if roomDisplayName != nil {
                if contentDisplay != nil {
                    locKey = "MSG_FROM_USER_IN_ROOM_WITH_CONTENT"
                    locArgs = [fromDisplay, roomDisplayName!, contentDisplay!]
                } else if actionDisplay != nil {
                    locKey = "ACTION_FROM_USER_IN_ROOM"
                    locArgs = [roomDisplayName!, fromDisplay, actionDisplay!]
                } else {
                    locKey = "MSG_FROM_USER_IN_ROOM"
                    locArgs = [fromDisplay, roomDisplayName!]
                }
            } else {
                if contentDisplay != nil {
                    locKey = "MSG_FROM_USER_WITH_CONTENT"
                    locArgs = [fromDisplay, contentDisplay!]
                } else if actionDisplay != nil {
                    locKey = "ACTION_FROM_USER"
                    locArgs = [fromDisplay, actionDisplay!]
                } else {
                    locKey = "MSG_FROM_USER"
                    locArgs = [fromDisplay]
                }
            }

            break

        case "m.call.invite":
            locKey = "VOICE_CALL_FROM_USER"
            locArgs = [fromDisplay]
            break

        case "m.room.member":
            if notification.userIsTarget! {
                if let membership = notification.membership, membership == "invite" {
                    payload.extra["category"] = "ROOM_INVITE"
                    if let roomName = notification.roomName {
                        locKey = "USER_INVITE_TO_NAMED_ROOM"
                        locArgs = [fromDisplay, roomName]
                    } else if let roomAlias = notification.roomAlias {
                        locKey = "USER_INVITE_TO_NAMED_ROOM"
                        locArgs = [fromDisplay, roomAlias]
                    } else {
                        locKey = "USER_INVITE_TO_CHAT"
                        locArgs = [fromDisplay]
                    }
                }
            }
            break

        default:
            /// A type of message was received that we don't know about
            /// but it was important enough for a push to have got to us
            locKey = "MSG_FROM_USER"
            locArgs = [fromDisplay]
            payload.extra["category"] = "MESSAGE"
            break
        }

        payload.extra["loc-key"] = locKey
        payload.extra["loc-args"] = try locArgs?.makeNode()

        return payload
    }

    private func getSenderName(_ notification: Notification) -> String {
        return notification.senderDisplayName ?? notification.sender
    }

    private func getBadge(_ notification: Notification) -> Int? {
        if let counts = notification.counts {
            var badge = 0

            if let unread = counts.unread {
                badge = badge + unread
            }

            if let missedCalls = counts.missedCalls {
                badge = badge + missedCalls
            }

            return badge
        }

        return nil
    }
}
