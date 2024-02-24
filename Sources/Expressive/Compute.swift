//
// Copyright © 2024 Antonio Marques. All rights reserved.
//

import Foundation

extension Expression {
    var computed: Expression {
        if let t = self.tupleContent {
            return Self.computed(
                lhs: t.lhs.computed,
                op: t.op,
                rhs: t.rhs.computed
            )
        }
        return self
    }

    static func computed(lhs: Expression, op: Op, rhs: Expression) -> Expression {
        let lhsn = lhs.nuggleContent
        let rhsn = rhs.nuggleContent
        if let lhsn = lhsn, let rhsn = rhsn {
            return .nuggle(op.nuggle(lhsn, rhsn).simplified)
        }

        if let lhst = lhs.tupleContent,
            rhs.isNumeric,
            op == .times || op == .by {
            if lhst.op == .plus || lhst.op == .minus {
                return Expression(
                    lhs: Expression(lhs: lhst.lhs, op: op, rhs: rhs),
                    op: lhst.op,
                    rhs: Expression(lhs: lhst.rhs, op: op, rhs: rhs)
                ).computed
            } else if lhst.op == .times || lhst.op == .by  {
                if lhst.lhs.isNumeric {
                    return Expression(
                        lhs: Expression(lhs: lhst.lhs, op: op, rhs: rhs),
                        op: lhst.op,
                        rhs: lhst.rhs
                    ).computed
                } else if lhst.rhs.isNumeric {
                    return Expression(
                        lhs: lhst.lhs,
                        op: lhst.op,
                        rhs: Expression(lhs: lhst.rhs, op: op, rhs: rhs)
                    ).computed
                }
            }
        }

        if let rhst = rhs.tupleContent,
            lhs.isNumeric,
            op == .times {
            if rhst.op == .plus || rhst.op == .minus {
                return Expression(
                    lhs: lhs * rhst.lhs,
                    op: rhst.op,
                    rhs: lhs * rhst.rhs
                ).computed
            } else if rhst.op == .times {
                if rhst.lhs.isNumeric {
                    return Expression(
                        lhs: Expression(lhs: lhs, op: op, rhs: rhst.lhs),
                        op: rhst.op,
                        rhs: rhst.rhs
                    ).computed
                } else if rhst.rhs.isNumeric {
                    return Expression(
                        lhs: rhst.lhs,
                        op: rhst.op,
                        rhs: Expression(lhs: lhs, op: op, rhs: rhst.rhs)
                    ).computed
                }
            } else if rhst.op == .by {
                if rhst.lhs.isNumeric {
                    return Expression(
                        lhs: Expression(lhs: lhs, op: .times, rhs: rhst.lhs),
                        op: rhst.op,
                        rhs: rhst.rhs
                    ).computed
                } else if rhst.rhs.isNumeric {
                    return Expression(
                        lhs: rhst.lhs,
                        op: rhst.op,
                        rhs: Expression(lhs: rhst.rhs, op: .by, rhs: lhs)
                    ).computed
                }
            }
        }

        return Expression(lhs: lhs, op: op, rhs: rhs)
    }
}
