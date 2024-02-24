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
    case rad
}

extension Op {
    func nuggle(_ lhs: Nuggle, _ rhs: Nuggle) -> Nuggle {
        switch self {
        case .plus:  lhs + rhs
        case .minus: lhs - rhs
        case .times: lhs * rhs
        case .by:    lhs / rhs
        case .exp:   lhs ↗ rhs
        case .rad:   lhs √ rhs
        }
    }
    
    var isCommutative: Bool {
        switch self {
        case .plus:  true
        case .minus: false
        case .times: true
        case .by:    false
        case .exp:   false
        case .rad:   false
        }
    }
    
    var priority: Int {
        switch self {
        case .plus:  0
        case .minus: 0
        case .times: 100
        case .by:    100
        case .exp:   10000
        case .rad:   10000
        }
    }
}

extension Op {
    static var priorityClasses: [(rightAssociative: Bool, ops: [Op])] {
        [
            (true, [.exp, .rad]),
            (false, [.times, .by]),
            (false, [.plus, .minus]),
        ]
    }

    var isRightAssociative: Bool {
        switch self {
        case .plus:  false
        case .minus: false
        case .times: false
        case .by:    false
        case .exp:   true
        case .rad:   true
        }
    }
}

extension Op {
    var leftNeutralElement: Nuggle? {
        switch self {
        case .plus:  0
        case .minus: nil
        case .times: 1
        case .by:    nil
        case .exp:   nil
        case .rad:   1
        }
    }

    var rightNeutralElement: Nuggle? {
        switch self {
        case .plus:  0
        case .minus: 0
        case .times: 1
        case .by:    1
        case .exp:   1
        case .rad:   nil
        }
    }

    var leftAbsorbing: (element: Nuggle, result: Nuggle)? {
        switch self {
        case .plus:  nil
        case .minus: nil
        case .times: (0, 0)
        case .by:    (0, 0)
        case .exp:   (0, 0)
        case .rad:   nil
        }
    }

    var rightAbsorbing: (element: Nuggle, result: Nuggle)? {
        switch self {
        case .plus:  nil
        case .minus: nil
        case .times: (0, 0)
        case .by:    nil
        case .exp:   (0, 1)
        case .rad:   (0, 0)
        }
    }
}

extension Op {
    func isNeutralElement(_ nuggle: Nuggle?, isLhs: Bool) -> Bool {
        if let nuggle {
            return isLhs
            ? nuggle == leftNeutralElement
            : nuggle == rightNeutralElement
        }
        return false
    }

    func absorbingResult(_ nuggle: Nuggle?, isLhs: Bool) -> Nuggle? {
        if let nuggle {
            if isLhs {
                if let leftAbsorbing {
                    if nuggle == leftAbsorbing.element {
                        return leftAbsorbing.result
                    }
                }
            } else {
                if let rightAbsorbing {
                    if nuggle == rightAbsorbing.element {
                        return rightAbsorbing.result
                    }
                }
            }
        }
        return nil
    }
}

extension Expression {
    public static func joining(_ op: Op, _ terms: [Expression]) -> Expression? {
        if terms.count <= 1 { return terms.first }
        if op.isRightAssociative {
            return .tuple(terms.first!, op, joining(op, Array(terms.dropFirst()))!)
        } else {
            return .tuple(joining(op, Array(terms.dropLast()))!, op, terms.last!)
        }
    }
}
