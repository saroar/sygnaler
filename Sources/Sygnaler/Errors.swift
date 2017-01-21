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
