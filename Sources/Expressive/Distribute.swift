//
// Copyright © 2024 Antonio Marques. All rights reserved.
//

import Foundation
import Nuggle

extension Expression {
    var distributed: Expression {
        if let t = tupleContent {
            let lhs = t.lhs.distributed
            let rhs = t.rhs.distributed
            if t.op == .exp, let exp = rhs.solve().exactInt() {
                switch exp {
                case 0: return 1
                case 1: return lhs
                case 2: return (lhs * lhs).distributed
                default: return (lhs * lhs ↗ .nuggle(Nuggle(integerLiteral: exp - 1))).distributed
                }
            } else if t.op == .times {
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
                if tl?.op == .by && tr?.op == .by {
                    return (tl!.lhs * tr!.lhs) / (tl!.rhs * tr!.rhs)
                }
            }
            return .tuple(lhs, t.op, rhs)
        }
        return self
    }
}
