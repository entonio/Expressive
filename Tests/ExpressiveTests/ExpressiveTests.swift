import XCTest
@testable import Expressive

final class ExpressiveTests: XCTestCase {
    
    let PRE: Expression = "PRE"
    let VIG: Expression = "VIG"
    let NEX: Expression = "NEX"
    
    func testSimplification() throws {
        let F = "d" * "a" * "c" * "m"
        XCTAssertEqual(F.simplified, "a" * "c" * "d" * "m")
    }
    
    func testCommutativity() throws {
        let F =  "m" * "a"
        XCTAssertEqual(F, "a" * "m")
    }
    
    func testCommutativityAndPrecedence() throws {
        XCTAssertEqual(
            "a" ** 2 + "b" ** 3,
            "b" ** 3 + "a" ** 2
        )
        XCTAssertEqual(
            "a" ** (2 + "b" ** 3) + 1,
            1 + "a" ** ("b" ** 3 + 2)
        )
    }

    func test_plus() throws {
        let PE: Expression = 1.5 + 1.5
        let solved = PE.solve().nuggle()
        XCTAssertEqual(
            solved?.double(),
            3
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

    func test_by() throws {
        let PE: Expression = 1.5 / 0.1
        let solved = PE.solve().nuggle()
        XCTAssertEqual(
            solved?.double(),
            15
        )
    }

    func test_mix1() throws {
        let PE: Expression = (3 + 2.5) * 20
        let solved = PE.solve().nuggle()
        XCTAssertEqual(
            solved?.double(),
            (3 + 2.5) * 20
        )
    }

    func test_mix() throws {
        let PE: Expression = (3 + 2.5) * 20 / 5
        let solved = PE.solve().nuggle()
        XCTAssertEqual(
            solved?.double(),
            (3 + 2.5) * 20 / 5
        )
    }

    func testSolve() throws {
        let PE = (3 + PRE) * NEX / 5
        let solved = PE.solve(using: [PRE: 2, VIG: 1.5, NEX: 20]).nuggle()
        XCTAssertEqual(
            solved?.double(),
            ((3 + 2) * 20 / 5)
        )
    }

    func testSolveInt1() throws {
        let PV: Expression = 16 + 1.5 + (3 + 1.5) * (20 - 5) / 5
        let solved = PV.solve().nuggle()
        XCTAssertEqual(
            solved?.double(),
            31
        )
        XCTAssertEqual(
            solved?.exactInt(),
            Int(16 + 1.5 + (3 + 1.5) * (20 - 5) / 5)
        )
    }
        
    func testSolveInt() throws {
        let PV = 16 + VIG + (3 + VIG) * (NEX - 5) / 5
        let solved = PV.solve(using: [PRE: 2, VIG: 1.5, NEX: 20]).nuggle()
        XCTAssertEqual(
            solved?.double(),
            31
        )
        XCTAssertEqual(
            solved?.exactInt(),
            Int(16 + 1.5 + (3 + 1.5) * (20 - 5) / 5)
        )
    }
    
   /* func testSolveSimplifiedInt() throws {
        let PV = 16 as Expression + 1.5 as Expression + (3 as Expression + 1.5 as Expression) * (20 as Expression - 5 as Expression) / 5 as Expression
        XCTAssertEqual(
            PV.simplified.solve(using: []).asInt,
            Int(16 + 1.5 + (3 + 1.5) * (20 - 5) / 5)
        )
    }*/

    func testExpressible() throws {
        let PV1 = 16 + VIG + (3 + VIG) * (NEX - 5) / 5
        let PV2 = "16 +VIG + ( 3 +VIG) *(NEX -5)/ 5" as Expression
        let PV3 = "16 +VIG " as Expression + "( 3 +VIG) *(NEX -5)/ 5"
        XCTAssertEqual(
            PV1,
            PV2
        )
        XCTAssertEqual(
            PV1,
            PV3
        )
    }

    func testSolveSimplifiedUsingInt() throws {
        let PV = 16 + VIG + (3 + VIG) * (NEX - 5) / 5
        let values: [Expression : Expression] = [PRE: 2, VIG: 1.5, NEX: 20]
        let simplified = PV.simplified
        let solved = simplified.solve(using: values).nuggle()
        XCTAssertEqual(
            solved?.exactInt(),
            Int(exactly: 16 + 1.5 + (3 + 1.5) * (20 - 5) / 5)
        )
    }
    
    func testSolveSimplifiedUsingDouble() throws {
        let PV = 16 + VIG + (3 + VIG) * (NEX - 5) / 5
        let values: [Expression : Expression] = [PRE: 2, VIG: 1.5, NEX: 20]
        let simplified = PV.simplified
        let solved = simplified.solve(using: values).nuggle()
        XCTAssertEqual(
            solved?.double(),
            16 + 1.5 + (3 + 1.5) * (20 - 5) / 5
        )
    }
    
    /*
    16
    +
    VIG
    +
    [[3 × NEX] × 1 ∕ 5]
    +
    [-15 × 1 ∕ 5]
    +
    [[VIG × NEX] × 1 ∕ 5]
    +
    [[VIG × -5] × 1 ∕ 5]
    */
    /*
    [16 + VIG]
    +
    [
        [
            [1 ∕ 5 × -15]
            +
            [1 ∕ 5 × [3 × NEX]]]
        +
        [
            [1 ∕ 5 × [VIG × -5]]
            +
            [1 ∕ 5 × [VIG × NEX]]
        ]
    ]
     
     (16) +
     VIG +
     -3 +
     (1 ∕ 5) × (3) × NEX +
     (1 ∕ 5) × VIG × -5 +
     (1 ∕ 5) × VIG × NEX
     */
    /*
    
    [[16] + [VIG]]
    +
    [
        [
            (-3)
            +
            [
                (1 ∕ 5)
                ×
                [[3] × [NEX]]
            ]
        ]
        +
        [
            [
                (1 ∕ 5)
                ×
                [[VIG] × (-5)]
            ]
            +
            [
                (1 ∕ 5)
                ×
                [[VIG] × [NEX]]
            ]
        ]
    ]
    [[16] + [VIG]]
    +
    [
        [
            (-3)
            +
            [[0.6000000000000001] × [NEX]]
        ]
        +
        [
            [
                [VIG] × (-1)
            ]
            +
            [
                (1 ∕ 5)
                ×
                [[VIG] × [NEX]]
            ]
        ]
    ]
    
    [[16] + [VIG]] 
    +
    [
        [(-15 ∕ 5) + [(3 ∕ 5) × [NEX]]]
        +
        [
            [[VIG] × (-5 ∕ 5)]
            +
            [(1 ∕ 5) × [[VIG] × [NEX]]]
        ]
    ]
     
    
    [[16] + [VIG]]
    +
    [
        [(-3) + [(3 ∕ 5) × [NEX]]] 
        +
        [
            [[VIG] × (-1)] 
            +
            [
                (1 ∕ 5)
                ×
                [[VIG] × [NEX]]
            ]
        ]
    ]
     
     16 + VIG + -3 + 3 ∕ 5 × NEX + VIG × -1 + 1 ∕ 5 × VIG × NEX


     16 + VIG + (3 + VIG) × (NEX - 5) ∕ 5
     16 + VIG + (3 × NEX - 3 × 5 + VIG × NEX - VIG × 5) ∕ 5
     (16*5 + VIG*5 + 3 × NEX - 3 × 5 + VIG × NEX - VIG × 5) ∕ 5
     13 + VIG × NEX ∕ 5 + 3 × NEX ∕ 5
     13 + 
     VIG × NEX ∕ 5 +
     3/5 × NEX

     1/5 + 16 + 
     1/5 × VIG × NEX +
     1/5 × NEX +
     6/5 × VIG

     13 + VIG × NEX / 5 + 3/5 × NEX + 0
     */
    func testDescription() throws {
        let PV = 20 + VIG + (4 + VIG) * (NEX - 5) / 5
        XCTAssertEqual(
            "\(PV.simplified)",
            "16 + VIG × NEX ∕ 5 + 4/5 × NEX"
        )
    }

    func testDescription1() throws {
        let x1: Expression = "16 + VIG + (3 + VIG) * (NEX - 5) / 5"
        XCTAssertEqual(
            "\(x1)",
            String("16 + VIG + (3 + VIG) × (NEX - 5) ∕ 5")
        )
    }

    func testDescription2() throws {
        let x2: Expression = "16 + VIG + (3 ** 2 + VIG) * (NEX - 5) / 5"
        XCTAssertEqual(
            "\(x2)",
            String("16 + VIG + (3^2 + VIG) × (NEX - 5) ∕ 5")
        )
    }

    func testDescription3() throws {
        let x3: Expression = "  -16 + VIG + (3  **2 + VIG) * (NEX - 5) / 5"
        XCTAssertEqual(
            "\(x3)",
            String("0 - 16 + VIG + (3^2 + VIG) × (NEX - 5) ∕ 5")
        )
    }
}
