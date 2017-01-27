extension Notification {
    func send() throws -> [String] {
        return try Dispatcher.send(notification: self)
    }
}
