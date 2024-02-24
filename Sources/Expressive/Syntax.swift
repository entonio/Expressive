//
// Copyright © 2024 Antonio Marques. All rights reserved.
//

import Foundation
import Nuggle

extension Expression {
    public prefix static func - (operand: Self) -> Self {
        0 - operand
    }
}

prefix operator √

extension Expression {
    public prefix static func √ (operand: Self) -> Self {
        2 √ operand
    }
}

infix operator ↗ : ExponentiationPrecedence
infix operator √ : ExponentiationPrecedence

extension Expression {
    public static func +(lhs: Expression, rhs: Expression) -> Expression {
        .tuple(lhs, .plus, rhs)
    }
    public static func -(lhs: Expression, rhs: Expression) -> Expression {
        .tuple(lhs, .minus, rhs)
    }
    public static func *(lhs: Expression, rhs: Expression) -> Expression {
        .tuple(lhs, .times, rhs)
    }
    public static func /(lhs: Expression, rhs: Expression) -> Expression {
        .tuple(lhs, .by, rhs)
    }
    public static func ↗(lhs: Expression, rhs: Expression) -> Expression {
        .tuple(lhs, .exp, rhs)
    }
    public static func √(lhs: Expression, rhs: Expression) -> Expression {
        .tuple(lhs, .rad, rhs)
    }
}

infix operator ** : ExponentiationPrecedence

extension Expression {
    public static func **(lhs: Expression, rhs: Expression) -> Expression {
        lhs ↗ rhs
    }
}
