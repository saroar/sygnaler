import Vapor
import Fluent
import VaporAPNS

final class Pusher: Model {
    var id: Node?
    var name: String
    var bundleId: String
    var useVOIP: Bool = false
    var teamId: String
    var keyId: String
    var keyPath: String
    var enabled: Bool = true
    var sandbox: Bool = true

    // used by fluent internally
    var exists: Bool = false

    // MARK: NodeConvertible

    init(node: Node, in context: Context) throws {
        self.bundleId = try node.extract("bundle_id")
        self.name = try node.extract("name")
        self.useVOIP = try node.extract("voip")
        self.teamId = try node.extract("team_id")
        self.keyId = try node.extract("key_id")
        self.keyPath = try node.extract("key_path")
        self.enabled = try node.extract("enabled")
        self.sandbox = try node.extract("sandbox")
    }

    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
                "bundle_id": bundleId,
                "name": name,
                "voip": useVOIP,
                "team_id": teamId,
                "key_id": keyId,
                "enabled": enabled,
                "key_path": keyId,
                "sandbox": sandbox
        ])
    }
}
