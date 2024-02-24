//
// Copyright © 2024 Antonio Marques. All rights reserved.
//

import Foundation
import Nuggle

extension Expression {
    var nuggleContent: Nuggle? {
        if case let .nuggle(value) = self { value } else { nil }
    }

    var varContent: String? {
        if case let .variable(value) = self { value } else { nil }
    }

    var tupleContent: Tuple? {
        if case let .tuple(lhs, op, rhs) = self { (lhs, op, rhs) } else { nil }
    }
}
