//
//  IHOrderSortable.swift
//  IHeartEverything
//
//  Created by Nick Schelle on 2025-11-05.
//

import Foundation
import SwiftData
import SwiftUI

/// A protocol for persistent models that maintain a sortable order index.
///
/// Conforming models must include an integer `sortOrder` property representing
/// their position within an ordered collection. This property is used to
/// preserve and update the visual or logical ordering of items.
protocol IHOrderSortable: PersistentModel {
    var sortOrder: Int { get set }
}

extension Array where Element: IHOrderSortable {
    
    /// Renumbers elements sequentially between the given indices.
    ///
    /// - Parameters:
    ///   - startIndex: The first index to renumber. Defaults to `0`.
    ///   - endIndex: The last index to renumber. Defaults to the end of the array.
    ///
    /// This method updates each element’s `sortOrder` value so that it matches
    /// its index position, ensuring consistent and gap-free ordering.
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
    /// Moves one or more elements and reassigns sequential `sortOrder` values.
    ///
    /// - Parameters:
    ///   - source: The indices of the elements to move.
    ///   - destination: The target index to insert the moved elements.
    ///
    /// This method safely moves the specified elements to a new position and
    /// then renumbers the entire array to maintain valid, sequential ordering.
    /// Out-of-range destinations are clamped automatically.
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
