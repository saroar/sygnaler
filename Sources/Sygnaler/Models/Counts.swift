import Vapor

final class Counts: NodeConvertible {
    /// The number of unacknowledged missed calls a user has across all rooms of which
    /// they are a member.
    var missedCalls: Int?

    /// The number of unread messages a user has across all of the rooms they are a member of.
    var unread: Int?

    init(node: Node, in context: Context) throws {
        missedCalls = try node.extract("missed_calls")
        unread = try node.extract("unread")
    }

    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
                "missed_calls": missedCalls,
                "unread": unread,
        ])
    }
}
