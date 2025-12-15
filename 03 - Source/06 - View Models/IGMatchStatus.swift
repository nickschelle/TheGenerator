//
//  IGMatchStatus.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-10-25.
//

import Foundation

enum IGMatchStatus {
    case all
    case some
    case none
    
    static func evaluate<T: Hashable>(
        selection: some Collection<T>,
        in filtered: some Collection<T>
    ) -> Self {
        let selectionSet = Set(selection)
        let filteredSet = Set(filtered)
        let common = selectionSet.intersection(filteredSet)
        
        if selectionSet.isEmpty || common.isEmpty {
            return .none
        } else if common == selectionSet {
            return .all
        } else {
            return .some
        }
    }
    
    var systemImage: String {
        switch self {
        case .all: "checkmark.circle.fill"
        case .some: "minus.circle.fill"
        case .none: "circle"
        }
    }
}
