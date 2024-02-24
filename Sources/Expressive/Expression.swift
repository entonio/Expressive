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
    public static func == (lhs: Expression, rhs: Expression) -> Bool {
        let lhs = lhs.simplified
        let rhs = rhs.simplified
        if let lhsv = lhs.varContent {
            return lhsv == rhs.varContent
        }
        if let lhsn = lhs.nuggleContent {
            return lhsn == rhs.nuggleContent
        }
        if let lhst = lhs.tupleContent,
           let rhst = rhs.tupleContent {
            if lhst.op == rhst.op {
                if lhst.lhs == rhst.lhs && lhst.rhs == rhst.rhs {
                    return true
                }
                if lhst.op.isCommutative &&
                    lhst.lhs == rhst.rhs && lhst.rhs == rhst.lhs {
                    return true
                }
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

extension Expression: CustomStringConvertible {
    public var description: String {
        switch self {
        case .nuggle(let n): n.description
        case .variable(let v): v
        case .tuple(let lhs, let op, let rhs): "\(lhs.description(asOperandOf: op))\(op)\(rhs.description(asOperandOf: op))"
        }
    }
    
    private func description(asOperandOf outer: Op) -> String {
        if let inner = tupleContent?.op,
           inner.priority < outer.priority {
            return "(\(self))"
        }
        /*
        if rationalContent != nil {
            return "(\(self))"
        }
         */
        /*
        if isNumeric, computed.value()! < 0 {
            return "(\(self))"
        }
        */
        return "\(self)"
    }
}

extension Expression: CustomDebugStringConvertible {
    public var debugDescription: String {
        return description
    }
}
