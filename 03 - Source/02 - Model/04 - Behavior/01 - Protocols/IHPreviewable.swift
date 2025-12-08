//
//  IHPreviewable.swift
//  IHeartEverything
//
//  Created by Nick Schelle on 2025-09-21.
//

import Foundation
import SwiftData

/// A protocol for SwiftData models that provide mock data for SwiftUI previews.
///
/// Conforming types define static `previewData` to be used when
/// rendering mock content in Xcode previews or testing environments.
///
/// This helps ensure that views depending on persistent models can be
/// previewed without requiring a live data store.
protocol IHPreviewable: PersistentModel {
    /// A collection of example instances for SwiftUI previews.
    static var previewData: [Self] { get }
}
