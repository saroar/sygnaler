import XCTest

import Core
import HTTP

@testable import Vapor
@testable import Sygnaler

class SygnalerTests: XCTestCase {
    static var allTests = [
        ("testExampleEndpoint", testExampleEndpoint)
    ]

    func testExampleEndpoint() throws {
        let app = try Sygnaler(testing: true)
        let drop = try app.getDroplet()

        do {
            try drop.runCommands()
        } catch {
            drop.log.error("\(error)")
        }

        let request = try Request(method: .get, uri: "/version")

        let response = try drop.respond(to: request)
        XCTAssertEqual(response.status, .ok)
        
        let json = try JSON(bytes: response.body.bytes!)
        XCTAssertEqual(json["version"]?.string, "0.0.1-alpha")
    }
}

extension Sygnaler {
    func getDroplet() throws -> Droplet {
        return self.drop!
    }
}
