import Foundation
import Vapor
import VaporAPNS

extension Notification {
    func send() -> [String] {
        return Dispatcher.send(notification: self)
    }
}
