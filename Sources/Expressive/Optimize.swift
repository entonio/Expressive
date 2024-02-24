//
// Copyright © 2024 Antonio Marques. All rights reserved.
//

import Foundation

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
            let lhsc = t.lhs.performOptimization()
            let rhsc = t.rhs.performOptimization()
            let subchanges = lhsc.1 + rhsc.1
            if let (opt, changes) = t.op.optimized(lhs: lhsc.0, rhs: rhsc.0) {
                return (opt, changes + subchanges)
            }
            if subchanges > 0 {
                return (.tuple(lhsc.0, t.op, rhsc.0), subchanges)
            }
        }
        return (self, 0)
    }
}

extension Op {
    func optimized(lhs: Expression, rhs: Expression) -> (Expression, Int)? {
        if isCommutative,
            let opt = performOptimization(candidate: lhs, other: rhs, candidateIsLhs: true) {
            return opt
        }

        return performOptimization(candidate: rhs, other: lhs, candidateIsLhs: false)
    }

    func performOptimization(candidate: Expression, other: Expression, candidateIsLhs: Bool) -> (Expression, Int)? {
        if candidate.isNumeric {
            let candidateValue = candidate.solve().nuggle()!
            if let absorbingResult = absorbingResult(candidateValue, isLhs: candidateIsLhs) {
                return (.nuggle(absorbingResult), 1)
            }
            if isNeutralElement(candidateValue, isLhs: candidateIsLhs) {
                return (other, 1)
            }
        }
        return nil
    }
}
