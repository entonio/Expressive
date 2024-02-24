//
// Copyright © 2024 Antonio Marques. All rights reserved.
//

import Foundation
import Nuggle

public enum Op: Codable, CaseIterable {
    case plus
    case minus
    case times
    case by
    case exp
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
        case .minus: return ["-", "−", "﹣", "－", "֊", "᠆", "‐", "‑", "‒", "–", "—", "―", "⸺", "⸻", "﹘"]
        case .times: return ["*", "×", "⋅"]
        case .by:    return ["/", "⁄", "÷"]
        case .exp:   return ["^"]
        }
    }
}

extension Op: CustomStringConvertible {
    public var description: String {
        switch self {
        case .plus:  return " + "
        case .minus: return " - "
        case .times: return " × "
        case .by:    return " ∕ "
        case .exp:   return  "^"
        }
    }
}

extension Op: CustomDebugStringConvertible {
    public var debugDescription: String {
        return description.trimmingCharacters(in: .whitespaces)
    }
}

extension Op {
    func nuggle(_ lhs: Nuggle, _ rhs: Nuggle) -> Nuggle {
        switch self {
        case .plus:  lhs + rhs
        case .minus: lhs - rhs
        case .times: lhs * rhs
        case .by:    lhs / rhs
        case .exp:   lhs ** rhs
        }
    }
    
    var isCommutative: Bool {
        switch self {
        case .plus:  return true
        case .minus: return false
        case .times: return true
        case .by:    return false
        case .exp:   return false
        }
    }
    
    var priority: Int {
        switch self {
        case .plus:  return 0
        case .minus: return 0
        case .times: return 100
        case .by:    return 100
        case .exp:   return 10000
        }
    }
}

extension Op {
    static var priorityClasses: [(rightAssociative: Bool, ops: [Op])] {
        [
            (true, [.exp]),
            (false, [.times, .by]),
            (false, [.plus, .minus]),
        ]
    }
}

extension Op {
    var neutralElement: Nuggle {
        switch self {
        case .plus:  0
        case .minus: 0
        case .times: 1
        case .by:    1
        case .exp:   1
        }
    }

    var absorbingElement: Nuggle? {
        switch self {
        case .plus:  nil
        case .minus: nil
        case .times: 0
        case .by:    0
        case .exp:   nil
        }
    }
}

extension Op {
    func isNeutralElement(_ nuggle: Nuggle) -> Bool {
        nuggle == neutralElement
    }

    func isAbsorbingElement(_ nuggle: Nuggle) -> Bool {
        guard let absorbingElement else { return false }
        return nuggle == absorbingElement
    }
}
