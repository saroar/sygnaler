extension Notification {
    func send() throws -> [String] {
        return try Dispatcher.sharedInstance.send(notification: self)
    }
}
