import XCTest

import Core
import HTTP

@testable import Vapor
@testable import Sygnaler

class ErrorControllerTests: XCTestCase {
    private var drop: Droplet?

    static var allTests = [
            ("testIndexEndpoint", testIndexEndpoint),
            ("testShowEndpoint", testShowEndpoint)
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

    func testIndexEndpoint() throws {
        let request = try Request(method: .get, uri: "/api/errors")

        let response = try drop!.respond(to: request)

        XCTAssertEqual(response.status, .ok)

        let json = try JSON(bytes: response.body.bytes!)
        XCTAssertEqual(json.array?.count, 0)
    }

    func testShowEndpoint() throws {
        let request = try Request(method: .get, uri: "/api/errors/2")

        let response = try drop!.respond(to: request)
        XCTAssertEqual(response.status, .notFound)
    }
}
