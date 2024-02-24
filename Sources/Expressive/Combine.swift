//
// Copyright © 2024 Antonio Marques. All rights reserved.
//

import Foundation
import Nuggle

extension Expression {
    var combined: Expression {
        if let t = tupleContent,
           t.op == .plus || t.op == .times {
            var previousVar: VarExpression?
            let parts = parts(usingOp: t.op)
                .map {
                    if let variable = $0.solveForVar {
                        variable
                    } else if $0.isNumeric {
                        $0.solve().nuggle()!
                    } else {
                        $0
                    }
                }
                .sorted { (p1:Any, p2:Any) in
                    let v1 = p1 as? VarExpression
                    let v2 = p2 as? VarExpression
                    if let v1 {
                        if let v2 {
                            return v1.variable < v2.variable
                        } else {
                            return true
                        }
                    } else if v2 != nil {
                        return true
                    }
                    return true
                }
                .reduce(into: [Expression.nuggle(t.op.neutralElement)]) { list, part in
                    if let n = part as? Nuggle {
                        if t.op == .plus {
                            list[0] = list[0] + .nuggle(n)
                        } else if t.op == .times {
                            list[0] = list[0] * .nuggle(n)
                        }
                    } else if let currentVar = part as? VarExpression {
                        if let combined = try?  previousVar?.combine(varExpression: currentVar, op: t.op) {
                            previousVar = combined
                            list.removeLast()
                            list.append(combined.expression())
                        } else {
                            previousVar = currentVar
                            list.append(currentVar.expression())
                        }
                    } else {
                        list.append(part as! Expression)
                    }
                }
            return associate(parts, t.op)
        }
        return self
    }

    private func parts(usingOp: Op) -> [Expression] {
        if let t = self.tupleContent, t.op == usingOp {
            return t.lhs.parts(usingOp: t.op) + t.rhs.parts(usingOp: t.op)
        }
        return [self]
    }

    private func associate(_ parts: [Expression], _ op: Op) -> Expression {
        let (lhs, rest) = parts.firstAndRest!
        if rest.isEmpty {
            return lhs
        }
        let rhs = associate(Array(rest), op)
        if let lhsn = lhs.nuggle(), op.isNeutralElement(lhsn) {
            return rhs
        }
        return Expression(lhs: lhs, op: op, rhs: rhs)
    }
}
