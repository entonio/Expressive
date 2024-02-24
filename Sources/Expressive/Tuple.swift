//
// Copyright © 2024 Antonio Marques. All rights reserved.
//

import Foundation

typealias Tuple = (lhs: Expression, op: Op, rhs: Expression)

extension Expression {

    init(lhs: Expression, op: Op, rhs: Expression) {
        self = .tuple(lhs, op, rhs)
    }
}
