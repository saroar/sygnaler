import Vapor
import HTTP

public final class Application {
    public var drop: Droplet?

    public init(testing: Bool = false) throws {
        var args = CommandLine.arguments
        
        if testing {
            // Simulate passing `--env=testing` from the
            // command line if testing is true.
            args.append("/dummy/path/")
            args.append("prepare")
        }

        /// Droplets are service containers that make accessing all of Vapor's features easy.
        /// Just call `drop.run()` to serve your application or `drop.client()` to create a
        /// client for request data from other servers.
        let drop = Droplet(arguments: args)
        
        for provider in providers {
            try drop.addProvider(provider)
        }

        for preparation in preparations {
            drop.preparations.append(preparation)
        }

        /// Passes the Droplet to have routes added from the routes folder.
        routes(drop)

        /// Middleware is a great place to filter and modifying incoming requests and 
        /// outgoing responses.
        for middleware in middlewares {
            drop.middleware.append(middleware)
        }

        self.drop = drop
    }

    /// Starts the application by serving the Droplet.
    public func start() {
        drop?.run()
    }
}
