import Vapor
import Fluent

final class Error: Model {
    var id: Node?
    var token: String
    var lastFailureTs: Int
    var lastFailureType: Int
    var lastFailureCode: Int
    var tokenInvalidatedAt: Int
    var originalPayload: Node
    var apnsPayload: Node

    // used by fluent internally
    var exists: Bool = false

    // MARK: NodeConvertible

    init(node: Node, in context: Context) throws {
        self.id = try node.extract("id")
        self.token = try node.extract("token")
        self.lastFailureTs = try node.extract("last_failure_ts")
        self.lastFailureType = try node.extract("last_failure_type")
        self.lastFailureCode = try node.extract("last_failure_code")
        self.tokenInvalidatedAt = try node.extract("token_invalidated_at")
        self.originalPayload = try node.extract("original_payload")
        self.apnsPayload = try node.extract("apns_payload")
    }

    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
                "id": id,
                "token": token,
                "last_failure_ts": lastFailureTs,
                "last_failure_type": lastFailureType,
                "original_payload": originalPayload,
                "apns_payload": apnsPayload
        ])
    }
}
