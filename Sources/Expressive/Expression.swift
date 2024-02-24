//
// Copyright © 2024 Antonio Marques. All rights reserved.
//
// Project started 07/02/2024.
//

import Foundation
import Nuggle

public indirect enum Expression: Codable {
    case nuggle(_ content: Nuggle)
    case variable(_ content: String)
    case tuple(_ lhs: Expression, _ op: Op, _ rhs: Expression)
}

extension Expression: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        let lhss = lhs.simplified
        let rhss = rhs.simplified
        if let lhsv = lhss.varContent {
            return lhsv == rhss.varContent
        }
        if let lhsn = lhss.nuggleContent {
            return lhsn == rhss.nuggleContent
        }
        if let lhst = lhss.tupleContent,
           let rhst = rhss.tupleContent {
            if lhst.op == rhst.op {
                if lhst.lhs == rhst.lhs && lhst.rhs == rhst.rhs {
                    return true
                }
                if lhst.op.isCommutative &&
                    lhst.lhs == rhst.rhs && lhst.rhs == rhst.lhs {
                    return true
                }
            }
            if lhss.description == rhss.description {
                return true
            }
        }
        return false
    }
}

extension Expression {
    func isIdentical(to other: Self) -> Bool {
        switch self {
        case .nuggle(let n):
            if let o = other.nuggleContent {
                return n.isIdentical(to: o)
            }
        case let .variable(v):
            if let o = other.varContent {
                return v == o
            }
        case let .tuple(lhs, op, rhs):
            if let o = other.tupleContent {
                return op == o.op && lhs.isIdentical(to: o.lhs) && rhs.isIdentical(to: o.rhs)
            }
        }
        return false
    }
}

extension Expression: Hashable {
    public func hash(into hasher: inout Hasher) {
        if let content = self.varContent {
            hasher.combine(content)
        } else if let content = self.nuggleContent {
            hasher.combine(content)
        } else if let content = self.tupleContent {
            hasher.combine(content.lhs)
            hasher.combine(content.op)
            hasher.combine(content.rhs)
        }
    }
}
