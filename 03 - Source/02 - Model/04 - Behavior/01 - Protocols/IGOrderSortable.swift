//
//  IGOrderSortable.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-11-05.
//

import Foundation
import SwiftData
import SwiftUI

protocol IGOrderSortable: PersistentModel {
    var sortOrder: Int { get set }
}

extension Array where Element: IGOrderSortable {
    
    mutating func renumber(
        from startIndex: Int = 0,
        to endIndex: Int? = nil
    ) throws {
        
        guard !isEmpty else { return }
        
        let finalIndex = endIndex ?? count - 1
        
        guard startIndex >= 0,
              finalIndex >= startIndex,
              finalIndex < count else {
            throw RenumberError.invalidRange(start: startIndex, end: finalIndex, count: count)
        }
        
        for i in startIndex...finalIndex {
            self[i].sortOrder = i
        }
    }
    /*
    mutating func moveAndRenumber(from source: IndexSet, to destination: Int) {
        guard !isEmpty, !source.isEmpty else { return }
        
        let safeDestination = Swift.min(Swift.max(destination, 0), count)
        self.move(fromOffsets: source, toOffset: safeDestination)
        renumber()
    }
     */
}

enum RenumberError: Error, CustomStringConvertible {
    case invalidRange(start: Int, end: Int, count: Int)
    
    var description: String {
        switch self {
        case let .invalidRange(start, end, count):
            return "Invalid renumber range: start=\(start), end=\(end), count=\(count)"
        }
    }
}
