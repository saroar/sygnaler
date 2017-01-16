import XCTest
@testable import SygnalerTests

XCTMain([
        testCase(BasicControllerTests.allTests),
        testCase(ErrorControllerTests.allTests)
])
