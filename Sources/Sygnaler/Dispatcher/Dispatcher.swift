import Foundation
import Vapor
import VaporAPNS

struct Pusher {
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

public class Dispatcher {
    private static var MAX_TRIES = 3
    private static var logger: LogProtocol?

    private static var map: [String: Pusher] = [:]

    private static var `default`: Pusher?

    public static func getAppIds() -> [String] {
        return Array(self.map.keys)
    }

    public static func set(maxTries mt: Int) {
        self.MAX_TRIES = mt
    }

    public static func set(logger _logger: LogProtocol) {
        self.logger = _logger
    }

    static func append(id: String, sender: VaporAPNS, sandbox: Bool = false) {
        self.map[id] = Pusher(sender: sender, sandbox: sandbox)
    }

    static func append(id: String, pusher: Pusher) {
        self.map[id] = pusher
    }

    public static var count: Int {
        return self.map.count
    }

    static func send(notification: Notification) -> [String] {
        var rejected = [String]()
        var payload: Payload?
        let prio: ApplePushMessage.Priority = notification.priority == Priority.high ? .immediately : .energyEfficient

        for device in notification.devices {
            var tries = 0
            let appId = device.appId
            let pushKey = device.pushkey

            guard let pusher = map[appId] else {
                rejected.append(pushKey)
                self.logger?.info("Got notification for unknown app ID \(appId)")
                continue
            }

            if payload == nil {
                payload = self.buildPayload(notification: notification)
            }

            // Set tweaks for device

            let pushMessage = ApplePushMessage(priority: prio, payload: payload!, sandbox: pusher.sandbox)

            var shouldStop = false

            while tries < self.MAX_TRIES {

                let result = pusher.send(pushMessage, to: pushKey)

                switch (result) {
                case let .success(messageId, deviceToken, serviceStatus):
                    self.logger?.warning("[SENDING] \(notification.id): \(serviceStatus)")
                    shouldStop = serviceStatus == .success
                    break

                case let .error(messageId, deviceToken, error):
                    self.logger?.warning("[SENDING] \(notification.id): \(error)")
                    switch (error) {
                    case .tooManyRequests, .idleTimeout, .shutdown, .internalServerError, .serviceUnavailable:
                        shouldStop = false
                    default:
                        rejected.append(pushKey)
                        shouldStop = true
                    }
                    break

                case let .networkError(error):
                    self.logger?.warning("[SENDING] \(notification.id): \(error)")
                    shouldStop = false
                    break
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

    static func buildPayload(notification: Notification) -> Payload {
        let payload = Payload()

        var fromDisplay = notification.sender

        if let name = notification.senderDisplayName {
            fromDisplay = name
        }

        var locKey: String?
        var locArgs: [String]?

        switch (notification.type) {
        case "m.room.message", "m.room.encrypted":
            let roomDisplay: String? = notification.roomName ?? notification.roomAlias
            var contentDisplay, actionDisplay: String?
            var isImage = false

            if let content = notification.content?.node, let messageType: String = content["msgtype"]?.string,
               let body: String = content["body"]?.string {

                switch (messageType) {
                case "m.text":
                    contentDisplay = body
                    break
                case "m.emote":
                    actionDisplay = body
                    break
                case "m.image":
                    isImage = true
                    break
                default:
                    contentDisplay = body
                    break
                }
            }

            if roomDisplay != nil {
                if contentDisplay != nil {
                    locKey = "MSG_FROM_USER_IN_ROOM_WITH_CONTENT"
                    locArgs = [fromDisplay, roomDisplay!, contentDisplay!]
                } else if actionDisplay != nil {
                    locKey = "ACTION_FROM_USER_IN_ROOM"
                    locArgs = [roomDisplay!, fromDisplay, actionDisplay!]
                } else if isImage {
                    locKey = "IMAGE_FROM_USER_IN_ROOM"
                    locArgs = [fromDisplay, roomDisplay!]
                } else {
                    locKey = "MSG_FROM_USER_IN_ROOM"
                    locArgs = [fromDisplay, roomDisplay!]
                }
            } else {
                if contentDisplay != nil {
                    locKey = "MSG_FROM_USER_WITH_CONTENT"
                    locArgs = [fromDisplay, contentDisplay!]
                } else if actionDisplay != nil {
                    locKey = "ACTION_FROM_USER"
                    locArgs = [fromDisplay, actionDisplay!]
                } else if isImage {
                    locKey = "IMAGE_FROM_USER"
                    locArgs = [fromDisplay]
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
            break
        }

        if locKey != nil {
            payload.bodyLocKey = locKey
        }

        if locArgs != nil {
            payload.bodyLocArgs = locArgs
        }

        if let unread = notification.counts?.unread {
            payload.badge = unread
        }

        if let missedCalls = notification.counts?.missedCalls {
            if payload.badge == 0 {
                payload.badge = 0
            }

            payload.badge = payload.badge! + missedCalls
        }

        /*if locKey != nil {
         payload.contentAvailable = true
         }*/

        if locKey == nil, payload.badge == nil {
            self.logger?.warning("[PAYLOAD] \(notification.id): Nothing to do for alert of type \(notification.type)")
        }

        if locKey != nil, let roomId = notification.roomId {
            payload.extra["room_id"] = roomId
        }

        return payload
    }
}
