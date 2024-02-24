//
// Copyright © 2024 Antonio Marques. All rights reserved.
//

import Foundation

extension Expression {
    
    public func solve(using contents: [Expression : Int]) -> Expression {
        solve(using: contents.mapToExpressions)
    }

    @_disfavoredOverload
    public func solve(using contents: [Expression : Double]) -> Expression {
        solve(using: contents.mapToExpressions)
    }

    @_disfavoredOverload
    public func solve(using contents: [Expression : Expression] = [:]) -> Expression {
        if let t = self.tupleContent {
            return .tuple(
                t.lhs.solve(using: contents),
                t.op,
                t.rhs.solve(using: contents))
            .canonicalized
        }
        let replacement = contents[self]
        return replacement?.solve(using: contents) ?? self
    }
}
