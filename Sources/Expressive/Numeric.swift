//
// Copyright © 2024 Antonio Marques. All rights reserved.
//

import Foundation
import Nuggle

extension Expression: ExpressibleByIntegerLiteral {
    public init(integerLiteral: Int) {
        self = .nuggle(Nuggle(integerLiteral: integerLiteral))
    }
}

extension Expression: ExpressibleByFloatLiteral {
    public init(floatLiteral: Double) {
        self = .nuggle(Nuggle(floatLiteral: floatLiteral))
    }
}

extension Expression {
    init(_ numeric: any Numeric) {
        self = .nuggle(Nuggle(numeric))
    }
}

extension Expression {
    var isNumeric: Bool {
        switch self {
        case .nuggle: true
        case .tuple(let lhs, _, let rhs): rhs.isNumeric && lhs.isNumeric
        case .variable: false
        }
    }

    func nuggle() -> Nuggle? {
        switch self.canonicalized {
        case .nuggle(let n): n
        case .tuple: nil
        case .variable: nil
        }
    }
}

extension Expression {
    public func exactInt() -> Int? {
        nuggle()?.exactInt()
    }

    public func int() -> Int? {
        nuggle()?.int()
    }

    public func double() -> Double? {
        nuggle()?.double()
    }
}
