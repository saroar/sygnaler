import Vapor
import HTTP
import Routing

extension Application {
    public func routes(_ drop: Droplet) {

        drop.get { req in
            return try drop.view.make("welcome", [
                "version": drop.localization[req.lang, "welcome", "version"].makeNode(),
                "build": drop.config["app", "version"]!.makeNode()
                ])
        }

        drop.group("api") { api in
            api.resource("errors", ErrorController())
        }


        /// Here is an example of a route without a controller.
        ///
        /// This provides an endpoint to check that your  app version and
        /// datbase is working and what version it's running.
        drop.get("version") {_ in
            guard let database = drop.database else {
                return "Your database is not set up. Please see the README.md."
            }

            guard let version = try database.driver.raw("SELECT @@version AS version")[0]?.object?["version"]?.string else {
                return JSON(["error": "Could not get database version."])
            }

            let appVersion = drop.config["app", "version"]?.string ?? "unknown"

            return JSON([
                "version": appVersion.makeNode(),
                "db-version": version.makeNode()
            ])
        }
    }
}
