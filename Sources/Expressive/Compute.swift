//
// Copyright © 2024 Antonio Marques. All rights reserved.
//

import Foundation

extension Expression {
    var computed: Expression {
        if let t = self.tupleContent {
            let lhs = t.lhs.computed
            let rhs = t.rhs.computed
            let op = t.op

            let lhsn = lhs.nuggleContent
            let rhsn = rhs.nuggleContent
            if let lhsn = lhsn, let rhsn = rhsn {
                return .nuggle(op.nuggle(lhsn, rhsn).simplified)
            }

            if let lhst = lhs.tupleContent,
               rhs.isNumeric,
               op == .times || op == .by {
                if lhst.op == .plus || lhst.op == .minus {
                    return .tuple(
                        .tuple(lhst.lhs, op, rhs),
                        lhst.op,
                        .tuple(lhst.rhs, op, rhs)
                    ).computed
                }
                if lhst.op == .times || lhst.op == .by {
                    if lhst.lhs.isNumeric {
                        return .tuple(
                            .tuple(lhst.lhs, op, rhs),
                            lhst.op,
                            lhst.rhs
                        ).computed
                    }
                    if lhst.rhs.isNumeric {
                        return .tuple(
                            lhst.lhs,
                            lhst.op,
                            .tuple(lhst.rhs, op, rhs)
                        ).computed
                    }
                }
            }

            if let rhst = rhs.tupleContent,
               lhs.isNumeric,
               op == .times {
                switch rhst.op {
                case .plus, .minus:
                    return .tuple(
                        lhs * rhst.lhs,
                        rhst.op,
                        lhs * rhst.rhs
                    ).computed

                case .times:
                    if rhst.lhs.isNumeric {
                        return .tuple(
                            .tuple(lhs, op, rhst.lhs),
                            rhst.op,
                            rhst.rhs
                        ).computed
                    }
                    if rhst.rhs.isNumeric {
                        return .tuple(
                            rhst.lhs,
                            rhst.op,
                            .tuple(lhs, op, rhst.rhs)
                        ).computed
                    }

                case .by:
                    if rhst.op == .by {
                        if rhst.lhs.isNumeric {
                            // A / (n / D) -> A * D / n
                            return .tuple(
                                .tuple(lhs, .times, rhst.lhs),
                                .by,
                                rhst.rhs
                            ).computed
                        }
                        if rhst.rhs.isNumeric {
                            // A / (D / n) -> n * A / D
                            return .tuple(
                                .tuple(rhst.rhs, .times, lhs),
                                .by,
                                rhst.lhs
                            ).computed
                        }
                    }

                default: break
                }
            }

            return .tuple(lhs, op, rhs)
        }
        return self
    }
}


