import XCTest
@testable import Expressive

final class ExpressiveTests: XCTestCase {

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

    func test_equality() throws {
        let F = "c" * "m" + "a" * "d"
        XCTAssertEqual(
            F.simplified,
            "a" * "d" + "c" * "m"
        )
    }

    func test_solve_polynomial() throws {
        try XCTSkipIf(true, "Completely simplifying complex expressions is a not a short term goal")

        let Px: Expression = "a x^2 + b x + c"
        let x1: Expression = "(-b + √[b^2 - 4a c]) / (2a)"
        let x2: Expression = "(-b - √[b^2 - 4a c]) / (2a)"

        XCTAssertEqual(Px.solve(using: ["x": x1]).simplified.description, "0")
        XCTAssertEqual(Px.solve(using: ["x": x2]).simplified.description, "0")
    }

    let PRE: Expression = "PRE"
    let VIG: Expression = "VIG"
    let NEX: Expression = "NEX"

    func test_solve_with_variables() throws {
        let PE = (3 + PRE) * NEX / 5
        let solved = PE.solve(using: [PRE: 2, VIG: 1.5, NEX: 20]).nuggle()
        XCTAssertEqual(
            solved?.double(),
            ((3 + 2) * 20 / 5)
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
        
    func test_solve_int_with_variables() throws {
        let PV = 16 + VIG + (3 + VIG) * (NEX - 5) / 5
        let solved = PV.solve(using: [PRE: 2, VIG: 1.5, NEX: 20]).nuggle()
        XCTAssertEqual(
            solved?.exactInt(),
            Int(16 + 1.5 + (3 + 1.5) * (20 - 5) / 5)
        )
    }

    func test_expressible_by_string() throws {
        let PV1 = 16 + VIG + (3 + VIG) * (NEX - 5) / 5
        let PV2: Expression = "16 +VIG + ( 3 +VIG) *(NEX -5)/ 5"
        let PV3 = "16+ VIG " as Expression + "( 3 +VIG) *(NEX -5)/ (5)"
        XCTAssertEqual(PV1, PV2)
        XCTAssertEqual(PV1, PV3)
        XCTAssertEqual(PV2, PV3)
    }

    func test_implicit_times() throws {
        let P: Expression = "2x^2 - 4x + c"
        let x: Expression = "x"
        let c: Expression = "c"
        XCTAssertEqual(P, 2 * x↗2 - 4*x + c)
    }

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

    func test_expressible_then_description() throws {
        let x1: Expression = "16 + VIG + (3 + VIG) * (NEX - 5) / 5"
        XCTAssertEqual(
            "\(x1)",
            String("16 + VIG + (3 + VIG)⋅(NEX - 5) ∕ 5")
        )

        let x2: Expression = "16 + VIG + (3 ↗ 2 + VIG) * (NEX - 5) / 5"
        XCTAssertEqual(
            "\(x2)",
            String("16 + VIG + (3^2 + VIG)⋅(NEX - 5) ∕ 5")
        )

        let x3: Expression = "  -16 + VIG + (3  ^2 + VIG) * (NEX - 5) / 5"
        XCTAssertEqual(
            "\(x3)",
            String("0 - 16 + VIG + (3^2 + VIG)⋅(NEX - 5) ∕ 5")
        )
    }
}
