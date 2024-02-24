import XCTest
@testable import Expressive

extension ExpressiveTests {

    func test_plus_commutativity() throws {
        let F: Expression = "m" + "a"
        XCTAssertEqual(F, "a" + "m")
    }

    func test_times_commutativity() throws {
        let F = "m" * "a"
        XCTAssertEqual(F, "a" * "m")
    }

    func test_commutativity_with_precedence() throws {
        XCTAssertEqual(
            "a" * 2 + "b" * 3,
            "b" * 3 + "a" * 2
        )
        XCTAssertEqual(
            "a" * (2 + "b" * 3) + 1,
            1 + "a" * ("b" * 3 + 2)
        )
        XCTAssertEqual(
            "a" ↗ 2 * "b" ↗ 3,
            "b" ↗ 3 * "a" ↗ 2
        )
        XCTAssertEqual(
            "a" ↗ (3 * "b" ↗ 5) * 7,
            7 * "a" ↗ ("b" ↗ 5 * 3)
        )
    }

    func test_equivalence() throws {
        let F = "c" * "m" + "a" * "d"
        XCTAssertEqual(
            F.simplified,
            "a" * "d" + "c" * "m"
        )
    }
}
