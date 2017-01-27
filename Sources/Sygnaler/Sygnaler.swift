import Vapor

public final class Sygnaler {
    public var drop: Droplet?

    public init(testing: Bool = false) throws {
        var args = CommandLine.arguments

        if testing {
            // Simulate passing `--env=testing` from the
            // command line if testing is true.
            args.append("prepare")
        }

        /// Droplets are service containers that make accessing all of Vapor's features easy.
        /// Just call `drop.run()` to serve your application or `drop.client()` to create a
        /// client for request data from other servers.
        self.drop = Droplet(arguments: args)

        for provider in providers {
            print(provider.name)
            self.drop!.addProvider(provider)
        }

        for preparation in preparations {
            self.drop!.preparations.append(preparation)
        }

        /// Passes the Droplet to have routes added from the routes folder.
        routes(self.drop!)

        try setupPushers(self.drop!)

        /// Middleware is a great place to filter and modifying incoming requests and 
        /// outgoing responses.
        for middleware in middlewares {
            self.drop!.middleware.append(middleware)
        }
    }

    /// Starts the application by serving the Droplet.
    public func start() {
        drop?.run()
    }
}
