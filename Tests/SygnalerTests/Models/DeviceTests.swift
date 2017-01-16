import XCTest

import Core
import HTTP

@testable import Vapor
@testable import Sygnaler

class DeviceTests: XCTestCase {
    private var drop: Droplet?

    static var allTests = [
            ("testWithMissingAppId", testWithMissingAppId),
            ("testWithMissingPushkey", testWithMissingPushkey),
            ("testWithData", testWithData)
    ]

    override func setUp() {
        super.setUp()
        do {
            let app = try Sygnaler(testing: true)
            self.drop = try app.getDroplet()
            try drop!.runCommands()
        } catch {
            print("\(error)")
        }
    }

    func testWithMissingAppId() throws {
        do {
            let _: Device = try Device(node: [
                    "pushkey": "PUSHKEY",
                    "pushkey_ts": 123456,
                    "data": [],
                    "tweaks": [
                            "sound": "default"
                    ]
            ])
            XCTAssertTrue(true)
        } catch let e as NotificationParseError {
            XCTAssertEqual(e, .noDeviceAppId)
        } catch {
            XCTFail("Wrong error")
        }
    }

    func testWithMissingPushkey() throws {
        do {
            let _: Device = try Device(node: [
                    "app_id": "APP_ID",
                    "pushkey_ts": 123456,
                    "data": [],
                    "tweaks": [
                            "sound": "default"
                    ]
            ])
            XCTAssertTrue(true)
        } catch let e as NotificationParseError {
            XCTAssertEqual(e, .noDeviceToken)
        } catch {
            XCTFail("Wrong error")
        }
    }

    func testWithData() throws {
        let d: Device = try Device(node: [
                "app_id": "APP_ID",
                "pushkey": "PUSHKEY",
                "pushkey_ts": 123456,
                "data": [],
                "tweaks": [
                        "sound": "default"
                ]
        ])
        XCTAssertEqual(d.appId, "APP_ID")
        XCTAssertEqual(d.pushkey, "PUSHKEY")
        XCTAssertEqual(d.pushkeyTs, 123456)
        XCTAssertEqual(d.data, [])
        XCTAssertNotNil(d.tweaks)
    }
}
