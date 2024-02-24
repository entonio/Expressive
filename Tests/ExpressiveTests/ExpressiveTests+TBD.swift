import XCTest
@testable import Expressive

extension ExpressiveTests {

    func test_solve_polynomial() throws {
        try XCTSkipIf(true, "Completely simplifying complex expressions is a not a short term goal")

        let Px: Expression = "a x^2 + b x + c"
        let x1: Expression = "(-b + √[b^2 - 4a c]) / (2a)"
        let x2: Expression = "(-b - √[b^2 - 4a c]) / (2a)"

        XCTAssertEqual(Px.solve(using: ["x": x1]).simplified.description, "0")
        XCTAssertEqual(Px.solve(using: ["x": x2]).simplified.description, "0")
    }
}
