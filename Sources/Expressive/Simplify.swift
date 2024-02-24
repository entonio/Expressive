//
// Copyright © 2024 Antonio Marques. All rights reserved.
//

import Foundation

extension Expression {

    var simplified: Expression {
        self.canonicalized
            .denormalized
    }

    var canonicalized: Expression {
        self.normalized
            .distributed
            .computed
            .combined
            .optimized
            .computed
    }
}
