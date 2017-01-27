import Vapor

extension Sygnaler {
    public func routes(_ drop: Droplet) {
        let basicController = BasicController(droplet: drop)
        basicController.addRoutes()

        let notificationController = NotificationController()
        notificationController.addRoutes(droplet: drop)
    }
}
