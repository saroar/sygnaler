import Vapor
import HTTP

public final class BasicController {
    let drop: Droplet

    public init(droplet: Droplet) {
        drop = droplet
    }

    func addRoutes() {
        drop.get("", handler: welcome)
        drop.get("version", handler: version)
    }

    func welcome(request: Request) throws -> ResponseRepresentable {
        return try drop.view.make("welcome", [
                "version": drop.localization[request.lang, "welcome", "version"].makeNode(),
                "build": drop.config["app", "version"]!.makeNode()
        ])
    }

    func version(request: Request) throws -> ResponseRepresentable {
        guard let database = drop.database else {
            return JSON(["error": "Your database is not set up. Please see the README.md."])
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
