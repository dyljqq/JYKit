import XCTest
@testable import JYKit

final class JYKitTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(JYKit().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
