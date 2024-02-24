//
// Copyright © 2024 Antonio Marques. All rights reserved.
//

import Foundation
import Nuggle

extension Expression: ExpressibleByStringLiteral {
    public init(stringLiteral: String) {
        try! self.init(stringExpression: stringLiteral)
    }
}

extension Expression {
    public init(stringExpression: String) throws {
        self = try Reader(context: stringExpression).read()
    }
}

extension Op {
    init(_ character: Character) throws {
        let match = Self.allCases.first {
            $0.characters.contains(character)
        }
        guard let match else {
            throw IllegalArgumentError("Could not create Op from character: [\(character)]")
        }
        self = match
    }

    static let allCharacters: [Character] = allCases.flatMap(\.characters)

    var characters: [Character] {
        switch self {
        case .plus:  return ["+", "＋"]
        case .minus: return ["-", "−", "﹣", "－", "֊", "᠆", "‐", "‑", "‒","–", "—", "―", "⸺", "⸻", "﹘"]
        case .times: return ["*", "×", "⋅"]
        case .by:    return ["/", "⁄", "÷"]
        case .exp:   return ["^", "↗"]
        case .rad:   return ["√"]
        }
    }
}

private class Reader {
    enum Token: CustomStringConvertible {
        case nuggle([Character])
        case variable([Character])
        case op(Op)
        case nested([Token])

        static var implicitZero: Self { .nuggle(["0"]) }
        static var implicitRadical: Self { .nuggle(["2"]) }

        static func combine(_ tokens: [Token]) -> Token {
            if tokens.count != 1 {
                return .nested(tokens)
            }
            let token = tokens.first!
            if let inner = token.value as? [Token] {
                return combine(inner)
            }
            return token
        }

        var value: Any {
            switch self {
            case .op(let op): op
            case .nuggle(let chars): chars
            case .variable(let chars): chars
            case .nested(let inner): inner
            }
        }

        var debugDescription: String {
            description
        }

        var description: String {
            switch self {
            case .op(let op): "\(op)"
            case .nuggle(let chars): String(chars)
            case .variable(let chars): String(chars)
            case .nested(let inner): "(\(inner.map(\.description).joined(separator: " ")))"
            }
        }
    }

    let context: String
    var position = 0

    init(context: String) {
        self.context = context
    }

    func read() throws -> Expression {
        var tokens = try readTokens(
            of: context.dropFirst(0)
        ).tokens
        if tokens.isEmpty {
            throw StringExpressionError("Expression is empty. Context: [\(context)]")
        }
        tokens = try normalize(tokens)
        tokens = try associate(tokens)
        return try expression(tokens)
    }

    func readTokens(of string: Substring, until delimiter: Character? = nil) throws -> (tokens: [Token], rest: Substring) {
        var foundDelimiter = false
        var tokens: [Token] = []
        var rest = string
        var currentToken: Token?
        while true {
            if rest.isEmpty {
                completeCurrentToken()
                break
            }

            let (c, r) = rest.firstAndRest!
            rest = r

            if c == delimiter {
                completeCurrentToken()
                foundDelimiter = true
                break
            } else if ["(", "[", "{"].contains(c) {
                completeCurrentToken()
                let (t, r) = try readTokens(of: rest, until: c.closingParens)
                rest = r
                if let first = t.first {
                    if t.count == 1 {
                        tokens.append(first)
                    } else {
                        tokens.append(.combine(t))
                    }
                }
            } else if Op.allCharacters.contains(c) {
                completeCurrentToken()
                tokens.append(.op(try Op(c)))
            } else if c.isNumber || c == "." || c == "," {
                if case .variable(let chars) = currentToken {
                    currentToken = .variable(chars + [c])
                } else if case .nuggle(let chars) = currentToken {
                    currentToken = .nuggle(chars + [c])
                } else {
                    currentToken = .nuggle([c])
                }
            } else if c.isLetter {
                if case .nuggle(_) = currentToken {
                    completeCurrentToken()
                    tokens.append(.op(.times))
                    currentToken = .variable([c])
                } else if case .variable(let chars) = currentToken {
                    currentToken = .variable(chars + [c])
                } else {
                    if case .variable(_) = tokens.last {
                        tokens.append(.op(.times))
                    }
                    currentToken = .variable([c])
                }
            } else if c.isWhitespace {
                completeCurrentToken()
            }
        }

        func completeCurrentToken() {
            if let token = currentToken {
                tokens.append(token)
                currentToken = nil
            }
        }

        if let delimiter, !foundDelimiter {
            throw StringExpressionError("Could not find delimiter '\(delimiter)'. Context: [\(context)] starting from \(count(string))")
        }

        return (tokens, rest)
    }

    func normalize(_ tokens: [Token]) throws -> [Token] {
        position = 0
        return try tokens.reduce(into: [Token]()) { list, current in
            position += 1
            let localPosition = position
            if let previous = list.last {
                switch current {
                case .nuggle(_), .variable(_):
                    switch previous {
                    case .nuggle(_), .variable(_):
                        throw syntaxError()
                    case .op(_):
                        list.append(current)
                    case .nested(_):
                        list.append(.op(.times))
                        list.append(current)
                    }
                case .op(let op):
                    if case .op(let previousOp) = previous {
                        if op == .minus {
                            list.append(.implicitZero)
                            list.append(current)
                        } else if op == .rad {
                            list.append(.implicitRadical)
                            list.append(current)
                        } else if op == .times && previousOp == .times {
                            list[list.count - 1] = .op(.exp)
                        } else {
                            throw syntaxError()
                        }
                    } else {
                        list.append(current)
                    }
                case .nested(let tokens):
                    if case .op(_) = previous {} else {
                        list.append(.op(.times))
                    }
                    list.append(.combine(try normalize(tokens)))
                }

                func syntaxError() -> Error {
                    StringExpressionError("Cannot have [\(current)] after [\(previous)]. Context: [\(context)], token: \(localPosition)")
                }

            } else {
                switch current {
                case .op(let op):
                    switch op {
                    case .plus:  break
                    case .minus:
                        list.append(.implicitZero)
                        list.append(current)
                    case .rad:
                        list.append(.implicitRadical)
                        list.append(current)
                    case .times, .by, .exp:
                        throw StringExpressionError("Cannot have [\(current)] at start of expression. Context: [\(context)], token: \(localPosition)")
                    }
                case .nested(let tokens):
                    list.append(.combine(try normalize(tokens)))
                default:
                    list.append(current)
                }
            }
        }
    }

    func associate(_ tokens: [Token]) throws -> [Token] {
        if tokens.count == 1 {
            return tokens
        }

        if tokens.count % 2 == 0 {
            throw StringExpressionError("Expression must have an odd number of tokens. Tokens: \(tokens). Context: [\(context)]")
        }

        try tokens.enumerated().forEach {
            if $0.offset % 2 == 0 {
                if case .op(_) = $0.element {
                    throw StringExpressionError("Cannot have an op at position \($0.offset). Tokens: \(tokens). Context: [\(context)]")
                }
            } else {
                guard case .op(_) = $0.element else {
                    throw StringExpressionError("Must have an op at position \($0.offset). Tokens: \(tokens). Context: [\(context)]")
                }
            }
        }

        var tokens = tokens

        // group stretches of the same class
        Op.priorityClasses.dropLast().forEach { priority in
            tokens = group(tokens, priority.ops)
        }

        // associate (left or right)
        Op.priorityClasses.forEach { priority in
            tokens = associate(tokens, priority.ops, priority.rightAssociative)
        }

        return tokens
    }

    func associate(_ tokens: [Token], _ ops: [Op], _ rightAssociative: Bool) -> [Token] {

        var tokens = tokens
        for (index, token) in tokens.enumerated() {
            if index % 2 == 0 {
                if case .nested(let inner) = token {
                    tokens[index] = .combine(associate(inner, ops, rightAssociative))
                }
            }
        }

        if tokens.count == 1 || tokens.count == 3 {
            return tokens
        }

        if !ops.contains(tokens[1].value as! Op) {
            return tokens
        }

        if (rightAssociative) {
            return [
                tokens[0],
                tokens[1],
                .combine(associate(
                    Array(tokens.dropFirst(2)),
                    ops,
                    rightAssociative
                )),
            ]
        } else {
            return [
                .combine(associate(
                    Array(tokens.dropLast(2)),
                    ops,
                    rightAssociative
                )),
                tokens[tokens.count - 2],
                tokens[tokens.count - 1],
            ]
        }
    }

    func group(_ tokens: [Token], _ ops: [Op]) -> [Token] {
        var tokens = tokens
        for (index, token) in tokens.enumerated() {
            if index % 2 == 0 {
                if case .nested(let inner) = token {
                    tokens[index] = .combine(group(inner, ops))
                }
            }
        }

        var result = [tokens.first!]
        var currentGroup: [Token]?
        for (index, token) in tokens.enumerated() {
            if index % 2 == 1 {
                let op = token.value as! Op
                let next = tokens[index + 1]
                if ops.contains(op) {
                    if currentGroup == nil {
                        let previous = result.popLast()!
                        currentGroup = [previous]
                    }
                    currentGroup?.append(token)
                    currentGroup?.append(next)
                } else {
                    if let group = currentGroup {
                        result.append(.combine(group))
                        currentGroup = nil
                    }
                    result.append(token)
                    result.append(next)
                }
            }
        }
        if let group = currentGroup {
            result.append(.combine(group))
            currentGroup = nil
        }

        return result
    }

    func expression(_ tokens: [Token]) throws -> Expression {
        guard tokens.count == 1 || tokens.count == 3 else {
            throw ReaderError("Illegal token array count: \(tokens). Context: [\(context)]")
        }

        let lhs = tokens[0]
        if case .op(_) = lhs {
            throw StringExpressionError("Cannot have an op as the leftmost/only element in an expression. Tokens: \(tokens). Context: [\(context)]")
        }

        if tokens.count == 1 {
            return try expression(lhs)
        }

        let mid = tokens[1]
        guard case .op(let op) = mid else {
            throw StringExpressionError("The middle element in an expression must be an op. Tokens: \(tokens). Context: [\(context)]")
        }

        let rhs = tokens[2]
        if case .op(_) = rhs {
            throw StringExpressionError("Cannot have an op as the rightmost element in an expression. Tokens: \(tokens). Context: [\(context)]")
        }

        return .tuple(
            try expression(lhs),
            op,
            try expression(rhs)
        )
    }

    func expression(_ token: Token) throws -> Expression {
        switch token {
        case .nuggle(let chars):
            guard let n = Nuggle(String(chars)) else {
                throw StringExpressionError("\(chars) is not convertible to number")
            }
            return .nuggle(n)

        case .variable(let chars):
            return .variable(String(chars))

        case .op(_):
            throw ReaderError("\(token) is not convertible to expression")

        case .nested(let inner):
            return try expression(inner)
        }
    }

    func count(_ string: Substring) -> Int {
        context.count - string.count
    }
}

struct ReaderError : Error {
    let message: String

    init(_ message: String) {
        self.message = message
    }
}

struct StringExpressionError : Error {
    let message: String

    init(_ message: String) {
        self.message = message
    }
}
