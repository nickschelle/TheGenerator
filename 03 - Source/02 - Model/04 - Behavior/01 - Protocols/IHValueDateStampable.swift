//
//  IHValueDateStampable.swift
//  IHeartEverything
//
//  Created by Nick Schelle on 2025-11-15.
//

import Foundation

// MARK: - IHValueDateStampable

/// A protocol for **value types** that track modification timestamps.
///
/// This parallels ``IHDateStampable`` but is designed for structs that may
/// participate in rendering, configuration, or snapshotting workflows without
/// being SwiftData models.
///
/// Conforming types must:
/// - store a `dateModified` property
/// - call `touch()` whenever a meaningful value mutation occurs
protocol IHValueDateStampable {

    /// The date the value was last modified.
    var dateModified: Date { get set }

    /// Updates the timestamp to the current moment.
    mutating func touch()
}

// MARK: - Default Implementation

extension IHValueDateStampable {

    /// Updates ``dateModified`` to the current time.
    mutating func touch() {
        dateModified = .now
    }
}
