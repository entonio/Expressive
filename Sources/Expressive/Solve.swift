//
// Copyright © 2024 Antonio Marques. All rights reserved.
//

import Foundation

extension Expression {
    public func solve(using substitutions: [Expression : Int]) -> Expression {
        solve(using: substitutions.mapToExpressions())
    }

    @_disfavoredOverload
    public func solve(using substitutions: [Expression : Double]) -> Expression {
        solve(using: substitutions.mapToExpressions())
    }

    @_disfavoredOverload
    public func solve(using substitutions: [Expression : Expression] = [:]) -> Expression {
        if let t = self.tupleContent {
            return .tuple(
                t.lhs.solve(using: substitutions),
                t.op,
                t.rhs.solve(using: substitutions)
            )
            .canonicalized
        }
        let replacement = substitutions[self]
        return replacement == self ? self : replacement?.solve(using: substitutions) ?? self
    }
}

extension Expression {
    public func replace(_ substitutions: [Expression : Int]) -> Expression {
        replace(substitutions.mapToExpressions())
    }

    @_disfavoredOverload
    public func replace(_ substitutions: [Expression : Double]) -> Expression {
        replace(substitutions.mapToExpressions())
    }

    @_disfavoredOverload
    public func replace(_ substitutions: [Expression : Expression] = [:]) -> Expression {
        if let t = self.tupleContent {
            return .tuple(
                t.lhs.replace(substitutions),
                t.op,
                t.rhs.replace(substitutions)
            ).optimized
        }
        let replacement = substitutions[self]
        return replacement == self ? self : replacement?.replace(substitutions) ?? self
    }
}
