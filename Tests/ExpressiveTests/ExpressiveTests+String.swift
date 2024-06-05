import XCTest
@testable import Expressive

extension ExpressiveTests {

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
            String("-16 + VIG + (3^2 + VIG)⋅(NEX - 5) ∕ 5")
        )
    }

    func test_print_options() throws {
        let x: Expression = "  -16 + VIG + (3  ^2 + VIG) * (NEX - 5) / 5"
        XCTAssertEqual(
            x.description(options: .init(allParens: true, radicalParens: "[", implicitMultiplication: false, multiplicationSign: "*")),
            String("((-16) + VIG) + ((((3^2) + VIG)*(NEX - 5)) ∕ 5)")
        )
    }

    func test_var_transform() throws {
        let x: Expression = "  -16 + VIG + (3  ^2 + VIG) * (NEX - 5) / 5"
        XCTAssertEqual(
            x.description(varTransform: {
                switch $0 {
                case "NEX": "xp"
                default: $0
                }
            }),
            String("-16 + VIG + (3^2 + VIG)⋅(xp - 5) ∕ 5")
        )
    }
}
