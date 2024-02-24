//
// Copyright © 2024 Antonio Marques. All rights reserved.
//

import Foundation

extension Expression {
    var normalized: Expression {
        if let t = self.tupleContent {
            var lhs = t.lhs.normalized
            var rhs = t.rhs.normalized
            if lhs.isNumeric && rhs.isNumeric {
                return Self.computed(lhs: lhs, op: t.op, rhs: rhs)
            }
            var op = t.op
            if op == .minus {
                op = .plus
                rhs = -1 * rhs
            } else if op == .by {
                op = .times
                rhs = 1 / rhs
            }
            if op.isCommutative && !lhs.isNumeric && rhs.isNumeric {
                (lhs, rhs) = (rhs, lhs)
            }
            return Expression(lhs: lhs, op: op, rhs: rhs)
        }
        return self
    }

    var denormalized: Expression {
        if let t = self.tupleContent {
            if t.op == .times {
                if let inverse = t.lhs.nuggleContent?.reciprocal().exactInt() {
                    return .tuple(t.rhs.denormalized, .by, Expression(inverse))
                }
                if let inverse = t.rhs.nuggleContent?.reciprocal().exactInt() {
                    return .tuple(t.lhs.denormalized, .by, Expression(inverse))
                }
            }
            return .tuple(t.lhs.denormalized, t.op, t.rhs.denormalized)
        }
        return self
    }
}
