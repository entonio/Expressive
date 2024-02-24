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
            var previousTerm: TermExpression?
            let parts = try! parts(usingOp: t.op)
                .map {
                    if let varExpression = $0.solveForVar {
                        varExpression
                    } else if let n = $0.solve().nuggle() {
                        n
                    } else {
                        $0.solveForTerm!
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
                    let n1 = p1 as? Nuggle
                    let n2 = p2 as? Nuggle
                    if let n1 {
                        if let n2 {
                            return n1 < n2
                        } else {
                            return true
                        }
                    } else if v2 != nil {
                        return true
                    }
                    let x1 = p1 as? TermExpression
                    let x2 = p2 as? TermExpression
                    if let x1 {
                        if let x2 {
                            return x1.term.description < x2.term.description
                        } else {
                            return true
                        }
                    } else if v2 != nil {
                        return true
                    }
                    throw IllegalArgumentError("Unexpected sort pair: [\(p1)] - [\(p2)]")
                }
                .reduce(into: [Expression.nuggle(t.op.leftNeutralElement!)]) { list, part in
                    if let n = part as? Nuggle {
                        if t.op == .plus {
                            list[0] = list[0] + .nuggle(n)
                        } else if t.op == .times {
                            list[0] = list[0] * .nuggle(n)
                        } else {
                            throw IllegalArgumentError("Unexpected op [\(t.op)] for combine")
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
                    } else if let currentTerm = part as? TermExpression {
                        if let combined = try?  previousTerm?.combine(termExpression: currentTerm, op: t.op) {
                            previousTerm = combined
                            list.removeLast()
                            list.append(combined.expression())
                        } else {
                            previousTerm = currentTerm
                            list.append(currentTerm.expression())
                        }
                    } else {
                        throw IllegalArgumentError("Unexpected part type: [\(part)]")
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
        if let lhsn = lhs.nuggle(), op.isNeutralElement(lhsn, isLhs: true) {
            return rhs
        }
        return .tuple(lhs, op, rhs)
    }
}
