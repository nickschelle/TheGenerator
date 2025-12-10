//
//  IGContentSelection.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-10-11.
//

import Foundation
import SwiftData

enum IGContentSelection: Equatable, Hashable {
    case allPhrases
    case renderQueue
    case uploadQueue
    case group(IGGroup)
    
    static var defaultValue: Self { .allPhrases }

    var group: IGGroup? {
        switch self {
        case .group(let group): group
        default: nil
        }
    }
    
    var isGroup: Bool {
        if case .group = self { true } else { false }
    }
}
