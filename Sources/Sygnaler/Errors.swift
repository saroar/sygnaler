enum AppError: Swift.Error, CustomStringConvertible {
    case noAppsConfigured
    case noPusherConfig
    case missingConfig(String, String)
    case custom(String)

    public var description: String {
        switch self {
        case .noAppsConfigured: return "No app IDs are configured. Edit Config/secrets/apps.json to define some."
        case .noPusherConfig: return "No pusher configuration file"
        case .missingConfig(let key, let app): return "Missing configuration: \(key) for \(app)"
        case .custom(let message): return message
        }
    }
}

enum NotificationParseError: Swift.Error, CustomStringConvertible {
    case noId
    case noType
    case noSender
    case noDeviceAppId
    case noDeviceToken

    public var description: String {
        switch self {
        case .noId: return "Notification with no id."
        case .noType: return "Notification with no type."
        case .noSender: return "Notification with no sender."
        case .noDeviceAppId: return "Device with no app_id."
        case .noDeviceToken: return "Device with no push token."
        }
    }
}
