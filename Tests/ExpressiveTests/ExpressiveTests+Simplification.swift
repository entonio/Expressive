import XCTest
@testable import Expressive

extension ExpressiveTests {

    func test_simplified_then_solve_int() throws {
        let PV = 16 + VIG + (3 + VIG) * (NEX - 5) / 5
        let values: [Expression : Expression] = [PRE: 2, VIG: 1.5, NEX: 20]
        let simplified = PV.simplified
        XCTAssertEqual(
            PV,
            simplified
        )

        let solved = simplified.solve(using: values).nuggle()
        XCTAssertEqual(
            solved?.exactInt(),
            Int(exactly: 16 + 1.5 + (3 + 1.5) * (20 - 5) / 5)
        )
    }
    
    func test_simplified_then_solve_double() throws {
        let PV = 20 + PRE + (4 + VIG) * (NEX - 5) / 5
        let values: [Expression : Expression] = [PRE: 2.5, VIG: 1.5, NEX: 25]
        let simplified = PV.simplified
        XCTAssertEqual(
            PV,
            simplified
        )

        let solved = simplified.solve(using: values).nuggle()
        XCTAssertEqual(
            solved?.double(),
            20 + 2.5 + (4 + 1.5) * (25 - 5) / 5
        )
    }
    
    func test_simplified_then_description() throws {
        let PV = 20 + VIG + ((NEX - 5) / 5) * (4 + VIG)
        XCTAssertEqual(
            "\(PV.simplified)",
            "16 + 4/5 NEX + VIG NEX ∕ 5"
        )
    }
}
