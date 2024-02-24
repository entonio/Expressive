//
// Copyright © 2024 Antonio Marques. All rights reserved.
//

import Foundation

extension Op {
    func optimized(lhs: Expression, rhs: Expression) -> (Expression, Int)? {
        if isCommutative,
            let opt = optimize(candidate: lhs, other: rhs) {
            return opt
        }

        return optimize(candidate: rhs, other: lhs)
    }

    func optimize(candidate: Expression, other: Expression) -> (Expression, Int)? {
        if candidate.isNumeric {
            let solved = candidate.solve()
            let value = solved.nuggle()!.simplified
            if isNeutralElement(value) {
                return other.performOptimization()
            } else if isAbsorbingElement(value) {
                return (solved, 1)
            }
        }
        return nil
    }
}

extension Expression {

    var optimized: Expression {
        var opt = (self, 0)
        while true {
            opt = opt.0.performOptimization()
            if opt.1 == 0 {
                return opt.0
            }
        }
    }

    func performOptimization() -> (Expression, Int) {
        if let t = self.tupleContent {
            if let (opt, changes) = t.op.optimized(lhs: t.lhs, rhs: t.rhs) {
                return (opt, changes)
            }
            let lhsc = t.lhs.performOptimization()
            let rhsc = t.rhs.performOptimization()
            return (
                Expression(
                    lhs: lhsc.0,
                    op: t.op,
                    rhs: rhsc.0
                ),
                lhsc.1 + rhsc.1
            )
        }
        return (self, 0)
    }
}
