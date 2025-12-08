//
//  IHDateStampable.swift
//  IHeartEverything
//
//  Created by Nick Schelle on 2025-11-15.
//

import Foundation
import SwiftData

// MARK: - IHDateStampable

/// A protocol for SwiftData models that track modification timestamps.
///
/// Conforming types must:
/// - store a `dateModified` property
/// - update that property whenever a meaningful change occurs
///
/// This protocol inherits from ``PersistentModel``, meaning all conformers
/// are SwiftData `@Model` classes and therefore main-actor isolated.
///
/// Both the protocol and its implementation must run on the main actor to
/// satisfy SwiftData’s mutation rules and avoid runtime warnings such as:
///
/// ```
/// ⚠️ Publishing changes from background threads is not allowed
/// ```
///
/// Example:
/// ```swift
/// @Model
/// final class IHTag: IHDateStampable {
///     var dateModified: Date = .now
///
///     func updateValue(_ newValue: String) {
///         value = newValue
///         touch()   // updates timestamp
///     }
/// }
/// ```
@MainActor
protocol IHDateStampable: PersistentModel {

    /// The date the object was last modified.
    var dateModified: Date { get set }

    /// Updates the modification timestamp to the current moment.
    func touch()
}

// MARK: - Default Implementation

extension IHDateStampable {

    /// Sets ``dateModified`` to the current date and time.
    ///
    /// Because conformers are SwiftData `@Model` types, this method is
    /// guaranteed to run on the main actor where SwiftData mutations occur.
    func touch() {
        dateModified = .now
    }
}
