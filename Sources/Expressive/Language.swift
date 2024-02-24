//
// Copyright © 2024 Antonio Marques. All rights reserved.
//

import Foundation

extension Collection {
    var firstAndRest: (first: Element, rest: SubSequence)? {
        guard let first = first else { return nil }
        return (first, dropFirst())
    }
}

extension Dictionary where Key == Expression, Value: Numeric {
    var mapToExpressions: Dictionary<Expression, Expression> {
        mapValues {
            Expression($0)
        }
    }
}

extension Character {
    var closingParens: Character? {
        switch self {
        case "(": ")"
        case "[": "]"
        case "{": "}"
        default: nil
        }
    }
}

class IllegalArgumentError: Error {
    let message: String

    init(_ message: String) {
        self.message = message
    }
}
