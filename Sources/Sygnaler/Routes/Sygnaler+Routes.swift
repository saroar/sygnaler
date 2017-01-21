import Vapor

extension Sygnaler {
    public func routes(_ drop: Droplet) {
        let basicController = BasicController(droplet: drop)
        basicController.addRoutes()

        drop.group("api") { api in
            api.resource("errors", ErrorController())
        }

        let notificationController = NotificationController()
        notificationController.addRoutes(droplet: drop)
    }
}
