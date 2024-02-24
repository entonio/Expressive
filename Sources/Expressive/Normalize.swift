//
// Copyright © 2024 Antonio Marques. All rights reserved.
//

import Foundation
import Nuggle

extension Expression {
    var normalized: Expression {
        if let t = self.tupleContent {
            var lhs = t.lhs.normalized
            var rhs = t.rhs.normalized
            if lhs.isNumeric, rhs.isNumeric {
                return .tuple(lhs, t.op, rhs).computed
            }
            var op = t.op
            if op == .minus {
                if lhs == rhs {
                    return 0
                }
                op = .plus
                rhs = -1 * rhs
            } else if op == .by {
                if lhs == rhs {
                    return 1
                }
                op = .times
                rhs = 1 / rhs
            } else if op == .rad {
                op = .exp
                (lhs, rhs) = (rhs, 1 / lhs)
            }
            if op.isCommutative, !lhs.isNumeric, rhs.isNumeric {
                (lhs, rhs) = (rhs, lhs)
            }
            return .tuple(lhs, op, rhs)
        }
        return self
    }
}

extension Expression {
    var denormalized: Expression {
        var den = (self, 0)
        while true {
            den = den.0.performDenormalization()
            if den.1 == 0 {
                den.0 = den.0.combined.optimized
                den = den.0.performDenormalization()
                return den.0
            }
        }
    }

    func performDenormalization() -> (Expression, Int) {
        if let t = self.tupleContent {
            let lhsc = t.lhs.performDenormalization()
            let rhsc = t.rhs.performDenormalization()
            let subchanges = lhsc.1 + rhsc.1
            if let (opt, changes) = t.op.denormalized(lhs: lhsc.0, rhs: rhsc.0), changes > 0 {
                return (opt, subchanges + changes)
            }
            if subchanges > 0 {
                return (.tuple(lhsc.0, t.op, rhsc.0), subchanges)
            }
        }
        return (self, 0)
    }
}

extension Op {
    func denormalized(lhs: Expression, rhs: Expression) -> (Expression, Int)? {
        if isCommutative,
            let opt = performDenormalization(candidate: lhs, other: rhs, candidateIsLhs: true) {
            return opt
        }

        return performDenormalization(candidate: rhs, other: lhs, candidateIsLhs: false)
    }

    func performDenormalization(candidate: Expression, other: Expression, candidateIsLhs: Bool) -> (Expression, Int)? {
        switch self {
        case .plus:
            switch candidate {
            case let .nuggle(n) where n < 0:
                //            -n +  B     -> B - n
                //             A + -n     -> A - n
                return (other - .nuggle(-n), 1)

            case let .tuple(clhs, op, crhs) where op == .times:
                //        -1 x A + B      -> B - A
                //             A + -1 x B -> A - B
                if let clhsn = clhs.solve().nuggle(), clhsn < 0 {
                    return (other - (.nuggle(-clhsn) * crhs), 1)
                }
                if let crhsn = crhs.solve().nuggle(), crhsn < 0 {
                    return (other - (.nuggle(-crhsn) * clhs), 1)
                }

            default: break
            }

        case .times:
            switch candidate {
            case let .nuggle(n) where -1 < n && n < 1:
                if n == 0 {
                    return (0, 1)
                }
                //          1/n x A      -> A / n
                let inverse = 1 / n
                if inverse.isExactInt() {
                    return (other / .nuggle(inverse) , 1)
                }

            case let .tuple(clhs, op, crhs) where op == .by:
                // (this may happen after a first denormalization step):
                //          n/B x A      -> n * A / B
                //            A x n/B    -> n * A / B
                if let clhsn = clhs.solve().nuggle() {
                    if clhsn != 1 {
                        return (.nuggle(clhsn) * other / crhs, 1)
                    } else {
                        return (other / crhs, 1)
                    }
                }
                //          B/n x A      -> A * B / n
                //            A x B/n    -> A * B / n
                if candidateIsLhs, let crhsn = crhs.solve().nuggle() {
                    return (other * clhs / .nuggle(crhsn), 1)
                }

            default: break
            }

        case .exp:
            if !candidateIsLhs {
                switch candidate {
                case let .nuggle(n) where -1 < n && n < 1:
                    //          A ^ 1/n      -> n √ A
                    let inverse = 1 / n
                    if inverse.isExactInt() {
                        return (.nuggle(inverse) √ other, 1)
                    }

                case let .tuple(clhs, op, crhs) where op == .by:
                    //          A ^ n/B      -> B/n √ A
                    if let clhsn = clhs.solve().nuggle() {
                        return ((crhs / .nuggle(clhsn)) √ other, 1)
                    }

                default: break
                }
            }

        default: break
        }
        return nil
    }
}
