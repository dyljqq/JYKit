import XCTest
@testable import JYKit

final class JYKitTests: XCTestCase {
    func testExample() {
      JYLeakSniffer.shared
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
