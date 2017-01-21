import Vapor
import HTTP

final class NotificationController {
    func addRoutes(droplet: Droplet) {
        droplet.post("matrix/push/v1/notify", handler: notify)
    }

    func notify(request: Request) throws -> ResponseRepresentable {
        let notification = try request.notification()

        if notification.devices.count == 0 {
            throw Abort.custom(status: .badRequest, message: "No devices in notification")
        }

        let rejected = try notification.send()

        return try JSON(node: [
                "rejected": rejected.makeJSON()
        ])
    }
}

extension Request {
    func notification() throws -> Notification {
        guard let json = json?["notification"] else {
            throw Abort.custom(status: .badRequest, message: "Invalid notification: expecting object in 'notification' key")
        }

        do {
            return try Notification(node: json)
        } catch {
            throw Abort.custom(status: .badRequest, message: "\(error)")
        }
    }
}
