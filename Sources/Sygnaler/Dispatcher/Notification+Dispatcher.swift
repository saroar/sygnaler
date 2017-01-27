import Foundation
import Vapor
import VaporAPNS

extension Notification {
    func send() throws -> [String] {
        return try Dispatcher.send(notification: self)
    }
}
