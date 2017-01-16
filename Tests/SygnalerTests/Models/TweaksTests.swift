import XCTest

import Core
import HTTP

@testable import Vapor
@testable import Sygnaler

class TweaksTests: XCTestCase {
    private var drop: Droplet?

    static var allTests = [
            ("testWithNoData", testWithNoData),
            ("testWithData", testWithData)
    ]

    override func setUp() {
        do {
            let app = try Sygnaler(testing: true)
            self.drop = try app.getDroplet()
            try drop!.runCommands()
        } catch {
            print("\(error)")
        }
    }

    func testWithNoData() throws {
        let tweaks = try Tweaks(node: [])

        XCTAssertNotNil(tweaks)
        XCTAssertNil(tweaks.sound)
    }

    func testWithData() throws {
        let tweaks = try Tweaks(node: [
                "sound": "default"
        ])

        XCTAssertEqual(tweaks.sound, "default")
    }
}
