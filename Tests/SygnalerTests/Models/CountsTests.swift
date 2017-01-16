import XCTest

import Core
import HTTP

@testable import Vapor
@testable import Sygnaler

class CountsTests: XCTestCase {
    private var drop: Droplet?

    static var allTests = [
            ("testWithNoData", testWithNoData),
            ("testWithUnread", testWithUnread),
            ("testWithMissedCalls", testWithMissedCalls),
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
        let count = try Counts(node: [])

        XCTAssertNotNil(count)
        XCTAssertNil(count.unread)
        XCTAssertNil(count.missedCalls)
    }

    func testWithUnread() throws {
        let count = try Counts(node: [
                "unread": 3
        ])

        XCTAssertEqual(count.unread, 3)
        XCTAssertNil(count.missedCalls)
    }

    func testWithMissedCalls() throws {
        let count = try Counts(node: [
                "missed_calls": 4
        ])

        XCTAssertNil(count.unread)
        XCTAssertEqual(count.missedCalls, 4)
    }

    func testWithData() throws {
        let count = try Counts(node: [
                "missed_calls": 4,
                "unread": 3
        ])

        XCTAssertEqual(count.unread, 3)
        XCTAssertEqual(count.missedCalls, 4)
    }
}
