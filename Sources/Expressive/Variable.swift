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
    func combine(nuggle: Nuggle, op: Op, ltr: Bool) -> VarExpression {
        return .init(
            multiplier: ltr ? op.nuggle(multiplier, nuggle) : op.nuggle(nuggle, multiplier),
            variable: variable,
            exponent: exponent
        )
    }

    func combine(varExpression other: VarExpression, op: Op) throws -> VarExpression {
        guard variable == other.variable else {
            throw IllegalArgumentError("Cannot combine different variables [\(variable)] and [\(other.variable)]")
        }
        switch op {
        case .plus:
            guard exponent == other.exponent else {
                throw IllegalArgumentError("Cannot sum different exponents [\(exponent)] and [\(other.exponent)]")
            }
            return .init(
                multiplier: multiplier + other.multiplier,
                variable: variable,
                exponent: exponent
            )
        case .by:
            return .init(
                multiplier: multiplier * other.multiplier,
                variable: variable,
                exponent: exponent + other.exponent
            )
        default:
            throw IllegalArgumentError("Can only add or multiply variables")
        }
    }
}

extension VarExpression {
    func expression() -> Expression {
        var expression = Expression.variable(variable)
        if exponent != 1 {
            expression = expression ** .nuggle(exponent)
        }
        if multiplier != 1 {
            expression = .nuggle(multiplier) * expression
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
                } else if let rhsn = rhs.solve().nuggle() {
                    return lhsv.combine(nuggle: rhsn, op: op, ltr: true)
                }
            } else if let rhsv = rhs.solveForVar, let lhsn = lhs.solve().nuggle() {
                return rhsv.combine(nuggle: lhsn, op: op, ltr: false)
            }
            return nil
        }
    }
}
