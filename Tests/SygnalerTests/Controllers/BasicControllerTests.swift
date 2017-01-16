import XCTest

import Core
import HTTP

@testable import Vapor
@testable import Sygnaler

class BasicControllerTests: XCTestCase {
    private var drop: Droplet?

    static var allTests = [
            ("testWelcomeEndpoint", testWelcomeEndpoint),
            ("testVersionEndpoint", testVersionEndpoint)
    ]

    override func setUp() {
        do {
            self.drop = try Sygnaler(testing: true).getDroplet()
            try self.drop!.runCommands()
        } catch {
            print("ERROR: \(error)")
        }
    }

    override func tearDown() {
        self.drop = nil
    }

    func testWelcomeEndpoint() throws {
        let request = try Request(method: .get, uri: "/")

        let response = try self.drop!.respond(to: request)
        XCTAssertEqual(response.status, .ok)

        let html = try response.body.bytes!.string()
        XCTAssertTrue(html.contains("0.0.1-alpha"))
    }

    func testVersionEndpoint() throws {
        let request = try Request(method: .get, uri: "/version")

        let response = try self.drop!.respond(to: request)
        XCTAssertEqual(response.status, .ok)

        let json = try JSON(bytes: response.body.bytes!)
        XCTAssertEqual(json["version"]?.string, "0.0.1-alpha")
    }
}
