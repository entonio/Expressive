//
// Copyright © 2024 Antonio Marques. All rights reserved.
//

import Foundation
import Nuggle

struct TermExpression {
    let multiplier: Nuggle
    let term: Expression
    let exponent: Nuggle
}

extension TermExpression {
    func combine(nuggle: Nuggle, op: Op, termIsLhs: Bool) throws -> TermExpression {
        switch op {
        case .times:
            return .init(
                multiplier: termIsLhs
                ? op.nuggle(multiplier, nuggle)
                : op.nuggle(nuggle, multiplier),
                term: term,
                exponent: exponent
            )

        case .by:
            guard termIsLhs else {
                throw IllegalArgumentError("Cannot combine number having the term as denominator")
            }
            return .init(
                multiplier: op.nuggle(multiplier, nuggle),
                term: term,
                exponent: exponent
            )

        case .exp:
            guard termIsLhs else {
                throw IllegalArgumentError("Cannot combine number having the term as exponent")
            }
            return .init(
                multiplier: multiplier,
                term: term,
                exponent: exponent * nuggle
            )

        case .rad:
            guard !termIsLhs else {
                throw IllegalArgumentError("Cannot combine number having the term as the radical index")
            }
            return .init(
                multiplier: multiplier,
                term: term,
                exponent: exponent / nuggle
            )

        default:
            throw IllegalArgumentError("Cannot combine number using \(op)")
        }
    }

    func combine(termExpression other: TermExpression, op: Op) throws -> TermExpression {
        guard term == other.term else {
            throw IllegalArgumentError("Cannot combine different terms [\(term)] and [\(other.term)]")
        }

        switch op {
        case .plus:
            guard exponent == other.exponent else {
                throw IllegalArgumentError("Cannot add with different exponents [\(exponent)] and [\(other.exponent)]")
            }
            return .init(
                multiplier: multiplier + other.multiplier,
                term: term,
                exponent: exponent
            )

        case .minus:
            guard exponent == other.exponent else {
                throw IllegalArgumentError("Cannot subtract with different exponents [\(exponent)] and [\(other.exponent)]")
            }
            return .init(
                multiplier: multiplier - other.multiplier,
                term: term,
                exponent: exponent
            )

        case .times:
            return .init(
                multiplier: multiplier * other.multiplier,
                term: term,
                exponent: exponent + other.exponent
            )

        case .by:
            return .init(
                multiplier: multiplier / other.multiplier,
                term: term,
                exponent: exponent - other.exponent
            )

        default:
            throw IllegalArgumentError("Can only add/subtract or multiply/divide terms")
        }
    }
}

extension TermExpression {
    func expression() -> Expression {
        if multiplier == 0 {
            return 0
        }
        var expression = term
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
    var solveForTerm: TermExpression? {
        switch self {
        case .nuggle(_): return nil

        case .variable(_): return .init(multiplier: 1, term: self, exponent: 1)

        case .tuple(let lhs, let op, let rhs):
            var lhss: TermExpression?
            var rhss: TermExpression?
            if let lhsv = lhs.solveForTerm {
                if let rhsv = rhs.solveForTerm {
                    if let combined = try? lhsv.combine(termExpression: rhsv, op: op) {
                        return combined
                    }
                    rhss = rhsv
                }
                let rhsl = rhs.solve()
                if let rhsn = rhsl.nuggle() {
                    if let combined = try? lhsv.combine(nuggle: rhsn, op: op, termIsLhs: true) {
                        return combined
                    }
                    rhss = .init(multiplier: 1, term: rhsl, exponent: 1)
                }
                lhss = lhsv
            } else if let rhsv = rhs.solveForTerm {
                let lhsl = lhs.solve()
                if let lhsn = lhsl.nuggle() {
                    if let combined = try? rhsv.combine(nuggle: lhsn, op: op, termIsLhs: false) {
                        return combined
                    }
                    lhss = .init(multiplier: 1, term: lhsl, exponent: 1)
                }
                rhss = rhsv
            }
            if lhss == nil && rhss == nil {
                return .init(multiplier: 1, term: self, exponent: 1)
            }
            return .init(multiplier: 1, term: .tuple(lhss?.expression() ?? lhs, op, rhss?.expression() ?? rhs), exponent: 1)
        }
    }
}
