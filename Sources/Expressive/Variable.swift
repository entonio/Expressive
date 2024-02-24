//
// Copyright © 2024 Antonio Marques. All rights reserved.
//

import Foundation
import Nuggle

struct VarExpression {
    let multiplier: Nuggle
    let variable: String
    let exponent: Nuggle
}

extension VarExpression {
    func combine(nuggle: Nuggle, op: Op, variableIsLhs: Bool) throws -> VarExpression {
        switch op {
        case .times:
            return .init(
                multiplier: variableIsLhs
                ? op.nuggle(multiplier, nuggle)
                : op.nuggle(nuggle, multiplier),
                variable: variable,
                exponent: exponent
            )

        case .by:
            guard variableIsLhs else {
                throw IllegalArgumentError("Cannot combine number having the variable as denominator")
            }
            return .init(
                multiplier: op.nuggle(multiplier, nuggle),
                variable: variable,
                exponent: exponent
            )

        case .exp:
            guard variableIsLhs else {
                throw IllegalArgumentError("Cannot combine number having the variable as exponent")
            }
            return .init(
                multiplier: multiplier,
                variable: variable,
                exponent: exponent * nuggle
            )

        case .rad:
            guard !variableIsLhs else {
                throw IllegalArgumentError("Cannot combine number having the variable as the radical index")
            }
            return .init(
                multiplier: multiplier,
                variable: variable,
                exponent: exponent / nuggle
            )

        default:
            throw IllegalArgumentError("Cannot combine number using \(op)")
        }
    }

    func combine(varExpression other: VarExpression, op: Op) throws -> VarExpression {
        guard variable == other.variable else {
            throw IllegalArgumentError("Cannot combine different variables [\(variable)] and [\(other.variable)]")
        }

        switch op {
        case .plus:
            guard exponent == other.exponent else {
                throw IllegalArgumentError("Cannot add with different exponents [\(exponent)] and [\(other.exponent)]")
            }
            return .init(
                multiplier: multiplier + other.multiplier,
                variable: variable,
                exponent: exponent
            )

        case .minus:
            guard exponent == other.exponent else {
                throw IllegalArgumentError("Cannot subtract with different exponents [\(exponent)] and [\(other.exponent)]")
            }
            return .init(
                multiplier: multiplier - other.multiplier,
                variable: variable,
                exponent: exponent
            )

        case .times:
            return .init(
                multiplier: multiplier * other.multiplier,
                variable: variable,
                exponent: exponent + other.exponent
            )

        case .by:
            return .init(
                multiplier: multiplier / other.multiplier,
                variable: variable,
                exponent: exponent - other.exponent
            )

        default:
            throw IllegalArgumentError("Can only add/subtract or multiply/divide variables")
        }
    }
}

extension VarExpression {
    func expression() -> Expression {
        if multiplier == 0 {
            return 0
        }
        var expression = Expression.variable(variable)
        if exponent != 1 {
            expression = expression ↗ .nuggle(exponent)
        }
        if multiplier != 1 {
            if multiplier != -1, let inverse = (1 / multiplier).exactInt() {
                expression = expression / .nuggle(Nuggle(integerLiteral: inverse))
            } else {
                expression = .nuggle(multiplier) * expression
            }
        }
        return expression
    }
}

extension Expression {
    var solveForVar: VarExpression? {
        switch self {
        case .nuggle(_): return nil

        case .variable(let name): return .init(multiplier: 1, variable: name, exponent: 1)

        case .tuple(let lhs, let op, let rhs):
            if let lhsv = lhs.solveForVar {
                if let rhsv = rhs.solveForVar {
                    return try? lhsv.combine(varExpression: rhsv, op: op)
                }
                if let rhsn = rhs.solve().nuggle() {
                    return try? lhsv.combine(nuggle: rhsn, op: op, variableIsLhs: true)
                }
            } else if let rhsv = rhs.solveForVar,
                        let lhsn = lhs.solve().nuggle() {
                return try? rhsv.combine(nuggle: lhsn, op: op, variableIsLhs: false)
            }
            return nil
        }
    }
}
