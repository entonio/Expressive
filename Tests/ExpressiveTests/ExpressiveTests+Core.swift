import XCTest
@testable import Expressive

final class ExpressiveTests: XCTestCase {

    let PRE: Expression = "PRE"
    let VIG: Expression = "VIG"
    let NEX: Expression = "NEX"

    func test_plus() throws {
        let PE: Expression = 2.5 + 1.5
        let solved = PE.solve().nuggle()
        XCTAssertEqual(
            solved?.double(),
            4
        )
    }

    func test_times() throws {
        let PE: Expression = 1.5 * 1.5
        let solved = PE.solve().nuggle()
        XCTAssertEqual(
            solved?.double(),
            2.25
        )
    }

    func test_minus() throws {
        let PE: Expression = "7 - 2 - 1"
        let solved = PE.solve().nuggle()
        XCTAssertEqual(
            solved?.double(),
            4
        )
    }

    func test_by() throws {
        let PE: Expression = 1.5 / 0.1
        let solved = PE.solve().nuggle()
        XCTAssertEqual(
            solved?.double(),
            15
        )
    }

    func test_times_with_plus() throws {
        let PE: Expression = (3 + 2.5) * 20
        let solved = PE.solve().nuggle()
        XCTAssertEqual(
            solved?.double(),
            (3 + 2.5) * 20
        )
    }

    func test_by_with_times_with_plus() throws {
        let PE: Expression = (3 + 2.5) * 20 / 5
        let solved = PE.solve().nuggle()
        XCTAssertEqual(
            solved?.double(),
            (3 + 2.5) * 20 / 5
        )
    }

    func test_solve_int() throws {
        let PV: Expression = 16 + 1.5 + (3 + 1.5) * (20 - 5) / 5
        let solved = PV.solve().nuggle()
        XCTAssertEqual(
            solved?.exactInt(),
            Int(16 + 1.5 + (3 + 1.5) * (20 - 5) / 5)
        )
    }

    func test_solve_with_variables() throws {
        let PE = (3 + PRE) * NEX / 5
        let solved = PE.solve(using: [PRE: 2, VIG: 1.5, NEX: 20]).nuggle()
        XCTAssertEqual(
            solved?.double(),
            ((3 + 2) * 20 / 5)
        )
    }
        
    func test_solve_int_with_variables() throws {
        let PV = 16 + VIG + (3 + VIG) * (NEX - 5) / 5
        let solved = PV.solve(using: [PRE: 2, VIG: 1.5, NEX: 20]).nuggle()
        XCTAssertEqual(
            solved?.exactInt(),
            Int(16 + 1.5 + (3 + 1.5) * (20 - 5) / 5)
        )
    }
}
