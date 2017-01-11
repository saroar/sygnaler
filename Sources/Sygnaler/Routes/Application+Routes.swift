import Vapor
import HTTP
import Routing

extension Application {
    public func routes(_ drop: Droplet) {
        
        drop.get { req in
            return try drop.view.make("welcome", [
                "message": drop.localization[req.lang, "welcome", "title"]
                ])
        }
        
        drop.get("test") { _ in return "Hello, World!" }
        
        drop.resource("posts", PostController())
        
        // MARK: Databse
        
        /// Here is an example of a route without a controller.
        ///
        /// This provides an endpoint to check that your datbase is working and
        /// what version it's running.
        drop.get("db-version") {_ in
            guard let database = drop.database else {
                return "Your database is not set up. Please see the README.md."
            }
            
            guard let version = try database.driver.raw("SELECT @@version AS version")[0]?.object?["version"]?.string else {
                return JSON(["error": "Could not get database version."])
            }
            
            return JSON([
                "version": version.makeNode()
            ])
        }
    }
}
