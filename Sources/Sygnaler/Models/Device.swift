import Vapor

final class Device: NodeConvertible {
    /// The app_id given when the pusher was created.
    var appId: String
    
    /// The pushkey given when the pusher was created.
    var pushkey: String
    
    /// The unix timestamp (in seconds) when the pushkey was last updated.
    var pushkeyTs: Int?
    
    /// A dictionary of additional pusher-specific data. For 'http' pushers, this is the data
    /// dictionary passed in at pusher creation minus the url key.
    var data: Node?
    
    /// A dictionary of customisations made to the way this notification is to be presented.
    /// These are added by push rules.}
    var tweaks: Tweaks?
    
    init(node: Node, in context: Context) throws {
        do {
            appId = try node.extract("app_id")
        } catch NodeError.unableToConvert {
           throw NotificationParseError.noDeviceAppId
        }
        
        do {
            pushkey = try node.extract("pushkey")
        } catch NodeError.unableToConvert {
            throw NotificationParseError.noDeviceToken
        }
        
        pushkeyTs = try node.extract("pushkey_ts")
        
        if let t: Node = try node.extract("tweaks") {
            tweaks = try Tweaks(node: t)
        }
        
        data = try node.extract("data")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "app_id": appId,
            "pushkey": pushkey,
            "pushkey_ts": pushkeyTs,
            "tweaks": tweaks,
            "data": data
            ])
    }
}
