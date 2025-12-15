//
//  IGTagScope.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-09-23.
//

import Foundation
import SwiftUI


enum IGTagScope: String, CaseIterable {
    
    case defaults
    case group
    case phrase
    case font
    case color
    case size
    case metadata
    case template
    case snapshot
}

extension IGTagScope {

    var precedence: Int {
        switch self {
        case .snapshot: 0
        case .color:    1
        case .font:     2
        case .metadata: 3
        case .size:     4
        case .template: 5
        case .defaults: 6
        case .group:    7
        case .phrase:   8
        }
    }
    
}

extension IGTagScope {
    
    var color: Color {
        switch self {
        case .defaults: .blue
        case .group:    .purple
        case .phrase:   .green
        case .snapshot: .cyan
        default:        .blue
        }
    }
    
    var display: String { rawValue.capitalized }
    
    static var defaultValue: Self { defaults }

    func hasTag(_ tag: IGTag) -> Bool {
        tag.links.contains {
            $0.sourceID == self.id &&
            $0.sourceScope == self
        }
    }
}

extension IGTagScope: Identifiable {
    
    var id: UUID {
        UUID(uuid: uuid_t(
            0,0,0,0,
            0,0,0,0,
            0,0,
            UInt8((self.precedence >> 8) & 0xFF),
            UInt8(self.precedence & 0xFF),
            0,0,0,0
        ))
    }
}

extension IGTagScope: Codable { }

extension IGTagScope: Hashable { }

extension IGTagScope: Comparable {
    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.precedence < rhs.precedence
    }
}
    

