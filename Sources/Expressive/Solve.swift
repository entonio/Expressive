//
// Copyright © 2024 Antonio Marques. All rights reserved.
//

import Foundation

infix operator ** : MultiplicationPrecedence

extension Expression {
    public static func +(lhs: Expression, rhs: Expression) -> Expression {
        Expression(lhs: lhs, op: .plus, rhs: rhs)
    }
    public static func -(lhs: Expression, rhs: Expression) -> Expression {
        Expression(lhs: lhs, op: .minus, rhs: rhs)
    }
    public static func *(lhs: Expression, rhs: Expression) -> Expression {
        Expression(lhs: lhs, op: .times, rhs: rhs)
    }
    public static func /(lhs: Expression, rhs: Expression) -> Expression {
        Expression(lhs: lhs, op: .by, rhs: rhs)
    }
    public static func **(lhs: Expression, rhs: Expression) -> Expression {
        Expression(lhs: lhs, op: .exp, rhs: rhs)
    }
}

extension Expression {
    
    public func solve(using contents: [Expression : Int]) -> Expression {
        solve(using: contents.mapToExpressions)
    }

    @_disfavoredOverload
    public func solve(using contents: [Expression : Double]) -> Expression {
        solve(using: contents.mapToExpressions)
    }

    func solve(using contents: [Expression : Expression] = [:]) -> Expression {
        if let t = self.tupleContent {
            return Expression(
                lhs: t.lhs.solve(using: contents),
                op: t.op,
                rhs: t.rhs.solve(using: contents))
            .canonicalized
        }
        let replacement = contents[self]
        return replacement?.solve(using: contents) ?? self
    }
}
