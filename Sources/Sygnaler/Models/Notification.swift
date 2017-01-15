import Vapor

enum Priority: String {
    case high
    case low
}

final class Notification: NodeConvertible {
    var id: String

    /// The type of the event as in the event's type field.
    /// Required if the notification relates to a specific Matrix event.
    var type: String

    /// The sender of the event as in the corresponding event field.
    /// Required if the notification relates to a specific Matrix event
    var sender: String

    /// The current display name of the sender in the room in which the event occurred.
    var senderDisplayName: String?

    /// The priority of the notification. If omitted, high is assumed. This may be used by push gateways to
    /// deliver less time-sensitive notifications in a way that will preserve battery power on mobile devices.
    /// One of: ["high", "low"]
    var priority: Priority

    /// The ID of the room in which this event occurred.
    /// Required if the notification relates to a specific Matrix event.
    var roomId: String?

    /// The name of the room in which the event occurred
    var roomName: String?

    var membership: String?

    /// An alias to display for the room in which the event occurred
    var roomAlias: String?

    ///  This is an array of devices that the notification should be sent to
    var devices = [Device]()

    /// The content field from the event, if present. If the event had no content field, this field is omitted.
    var content: Node?

    /// This is true if the user receiving the notification is the subject of a member event (i.e. the state_key of
    /// the member event is equal to the user's Matrix ID).
    var userIsTarget: Bool?

    /// This is a dictionary of the current number of unacknowledged communications for the recipient user.
    /// Counts whose value is zero are omitted.
    var counts: Counts?

    init(node: Node, in context: Context) throws {
        do {
            id = try node.extract("id")
        } catch {
            throw NotificationParseError.noId
        }

        do {
            type = try node.extract("type")
        } catch {
            throw NotificationParseError.noType
        }

        do {
            sender = try node.extract("sender")
        } catch {
            throw NotificationParseError.noSender
        }

        senderDisplayName = try node.extract("sender_display_name")

        if let prio = node["prio"]?.string {
            priority = Priority(rawValue: prio) ?? Priority.high
        } else {
            priority = Priority.high
        }

        roomId = try node.extract("room_id")
        roomName = try node.extract("room_name")
        roomAlias = try node.extract("room_alias")
        membership = try node.extract("membership")
        content = try node.extract("content")
        userIsTarget = try node.extract("user_is_target") ?? false

        if let deviceArray: [Node] = node["devices"]?.nodeArray {
            for device: Node in deviceArray {
                let d = try Device(node: device)
                devices.append(d)
            }
        }

        if let countNode: Node = try node.extract("counts") {
            counts = try Counts(node: countNode)
        }
    }

    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
                "id": id,
                "type": type,
                "sender": sender,
                "prio": priority.rawValue,
                "sender_display_name": senderDisplayName,
                "room_id": roomId,
                "room_name": roomName,
                "room_alias": roomAlias,
                "membership": membership,
                "user_is_target": userIsTarget,
                "content": content,
                "counts": counts?.makeNode(),
                "devices": devices.makeNode()
        ])
    }
}
