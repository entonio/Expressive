//
// Copyright © 2024 Antonio Marques. All rights reserved.
//

import Foundation

extension Expression {
    public struct PrintOptions {
        public let allParens: Bool
        public let radicalParens: Character
        public let implicitMultiplication: Bool
        public let multiplicationSign: String

        public static let `default` = Self(
            allParens: false,
            radicalParens: "[",
            implicitMultiplication: true,
            multiplicationSign: "⋅"
        )

        public static let plain = Self(
            allParens: true,
            radicalParens: "(",
            implicitMultiplication: false,
            multiplicationSign: "×"
        )
    }
}

extension Expression: CustomStringConvertible {
    public var description: String {
        description(options: .default)
    }

    public func description(options: PrintOptions) -> String {
        switch self {
        case .nuggle(let n): n.description
        case .variable(let v): v
        case .tuple(let lhs, let op, let rhs): "\(lhs.description(asLhsOf: op, options))\(op.description(lhs: lhs, rhs: rhs, options))\(rhs.description(asRhsOf: op, options))"
        }
    }

    private func description(asLhsOf outer: Op, _ options: PrintOptions) -> String {
        if outer == .minus, self == 0 {
            return ""
        }
        if outer == .times, self == -1 {
            return "-"
        }
        if let t = tupleContent,
            t.op == .times, t.lhs == -1 {
            return "(\(self))"
        }
        if outer == .rad {
            return self == 2 ? "" : "\(options.radicalParens)\(self)\(options.radicalParens.closingParens!)"
        }
        if let inner = tupleContent?.op {
            if options.allParens {
                return "(\(self))"
            }
            if inner != outer {
                if inner.priority < outer.priority {
                    return "(\(self))"
                }
            }
        }
        return "\(self)"
    }

    private func description(asRhsOf outer: Op, _ options: PrintOptions) -> String {
        if outer == .times, let t = tupleContent,
            t.op == .by, t.lhs == 1 {
            return "\(t.rhs.description(asRhsOf: t.op, options))"
        }
        if outer == .rad {
            return self == 2 ? "" : "\(options.radicalParens)\(self)\(options.radicalParens.closingParens!)"
        }
        if let inner = tupleContent?.op {
            if options.allParens {
                return "(\(self))"
            }
            if inner != outer {
                if inner.priority < outer.priority {
                    return "(\(self))"
                }
                if inner.priority == outer.priority,
                   !outer.isCommutative {
                    return "(\(self))"
                }
            }
        }
        return "\(self)"
    }
}

extension Expression: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .nuggle(let n): n.debugDescription
        case .variable(let v): v
        case .tuple(let lhs, let op, let rhs): "(\(lhs.debugDescription)\(op.debugDescription)\(rhs.debugDescription))"
        }
    }
}

extension Op: CustomStringConvertible {
    public var description: String {
        description(options: .default)
    }

    public func description(options: Expression.PrintOptions) -> String {
        switch self {
        case .plus:  return " + "
        case .minus: return " - "
        case .times: return options.multiplicationSign
        case .by:    return " ∕ "
        case .exp:   return  "^"
        case .rad:   return  "√"
        }
    }

    func description(lhs: Expression, rhs: Expression, _ options: Expression.PrintOptions) -> String {
        switch self {
        case .minus:
            if lhs.nuggleContent == 0 {
                return description.trimmingCharacters(in: .whitespaces)
            }
        case .times:
            if options.implicitMultiplication, rhs.nuggleContent == nil {
                if lhs.varContent != nil || lhs.isNumeric { return " " }
                if lhs.nuggle()?.isExactInt() == true { return "" }
            }
            if let tr = rhs.tupleContent, tr.op == .by, tr.lhs == 1 { return tr.op.description(options: options) }
        default: break
        }
        return description
    }
}

extension Op: CustomDebugStringConvertible {
    public var debugDescription: String {
        return description.trimmingCharacters(in: .whitespaces)
    }
}
