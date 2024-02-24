//
// Copyright © 2024 Antonio Marques. All rights reserved.
//

import Foundation

extension Expression {
    var distributed: Expression {
        if let t = tupleContent {
            let lhs = t.lhs.distributed
            let rhs = t.rhs.distributed
            if t.op == .times {
                let tl = lhs.tupleContent
                let tr = rhs.tupleContent
                let dl = tl?.op == .plus
                let dr = tr?.op == .plus
                if dl && dr {
                    // ((a * c) + (a * d)) + ((b * c) + (b * d))
                    return
                        (tl!.lhs * tr!.lhs + tl!.lhs * tr!.rhs) +
                        (tl!.rhs * tr!.lhs + tl!.rhs * tr!.rhs)
                } else if dl {
                    // (a * rhs) + (b * rhs)
                    return tl!.lhs * rhs + tl!.rhs * rhs
                } else if dr {
                    // (lhs * c) + (lhs * d))
                    return lhs * tr!.lhs + lhs * tr!.rhs
                }
            }
            return Expression(lhs: lhs, op: t.op, rhs: rhs)
        }
        return self
    }
}
