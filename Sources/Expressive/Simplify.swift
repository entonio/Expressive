//
// Copyright © 2024 Antonio Marques. All rights reserved.
//

import Foundation

typealias SimplificationTrace = [(String, Expression)]

extension Expression {

    var simplified: Expression {
        performSimplification(denormalize: true, trace: false)
            .last!.1
    }

    var simplifiedTrace: SimplificationTrace {
        performSimplification(denormalize: true, trace: true)
    }

    var canonicalized: Expression {
        performSimplification(denormalize: false, trace: false)
            .last!.1
    }

    private func performSimplification(denormalize: Bool, trace: Bool) -> SimplificationTrace {
        var result: SimplificationTrace? = trace ? [] : nil
        var x = self;       result?.append(("original", x))
        x = x.normalized;   result?.append(("normalized", x))
        x = x.distributed;  result?.append(("distributed", x))
        x = x.computed;     result?.append(("computed", x))
        x = x.combined;     result?.append(("combined", x))
        x = x.optimized;    result?.append(("optimized", x))
        x = x.computed;     result?.append(("computed", x))
        if denormalize {
            x = x.denormalized; result?.append(("denormalized", x))
        }
        return result ?? [("", x)]
    }
}
