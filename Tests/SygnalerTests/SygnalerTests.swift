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
        let app = try Application(testing: true)
        let drop = try app.getDroplet()
        
        do {
            try drop.runCommands()
        } catch {
            drop.log.error("\(error)")
        }
        
        let request = try Request(method: .get, uri: "/test")
        
        let response = try drop.respond(to: request)
        XCTAssertEqual(response.status, .ok)
        XCTAssertEqual(response.body.bytes?.string, "Hello, World!")
    }
}

extension Application {
    func getDroplet() throws -> Droplet {
        return self.drop!
    }
}
