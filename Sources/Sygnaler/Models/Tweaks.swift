import Vapor

final class Tweaks: NodeConvertible {
    var  sound: String?
    
    init(node: Node, in context: Context) throws {
        sound = try node.extract("sound")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "sound": sound,
            ])
    }
}
