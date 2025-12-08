//
//  PersistentModel+DisplayName.swift
//  IHeartEverything
//
//  Created by Nick Schelle on 2025-10-09.
//

import Foundation
import SwiftData

// MARK: - PersistentModel Display Name
//
// Adds user-facing naming utilities for any SwiftData `PersistentModel`.
// Automatically derives readable singular and plural display names
// from the model type by stripping the “IH” prefix and formatting in Title Case.

extension PersistentModel {
    
    // MARK: - Singular Display Name
    
    /// A user-friendly, human-readable name for the model type.
    ///
    /// Removes the internal `IH` prefix (e.g., `IHPhrase` → “Phrase”)
    /// and converts it to Title Case for UI display.
    ///
    /// Example:
    /// ```swift
    /// print(IHGroup.displayName)   // "Group"
    /// print(IHPhrase.displayName)  // "Phrase"
    /// print(IHTag.displayName)     // "Tag"
    /// ```
    static var displayName: String {
        String(describing: Self.self)
            .replacingOccurrences(of: "^IH", with: "", options: .regularExpression)
            .titleCased
    }
    
    
    // MARK: - Pluralized Display Name
    
    /// A pluralized, user-facing name that adapts to the given count.
    ///
    /// Automatically pluralizes the base display name for counts other than one.
    /// Optionally omits the number when below two (`includeNumberBelowTwo`).
    ///
    /// Example:
    /// ```swift
    /// IHPhrase.displayName(with: 1)  // "Phrase"
    /// IHPhrase.displayName(with: 5)  // "5 Phrases"
    /// IHPhrase.displayName(with: 1, includeNumberBelowTwo: false)  // "Phrase"
    /// ```
    ///
    /// - Parameters:
    ///   - count: The number of items to display.
    ///   - includeNumberBelowTwo: Whether to include a number prefix when count ≤ 1.
    /// - Returns: A formatted singular or plural display name.
    static func displayName(with count: Int, includeNumberBelowTwo: Bool = true) -> String {
        let name = count == 1 ? displayName : displayName.pluralized()
        let countPrefix = (count > 1 || includeNumberBelowTwo) ? "\(count) " : ""
        return countPrefix + name
    }
}
