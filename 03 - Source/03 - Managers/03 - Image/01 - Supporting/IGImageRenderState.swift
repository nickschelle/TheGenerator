//
//  IGImageGenerationState.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-11-XX.
//

import Foundation

enum IGImageGenerationState: Codable, Equatable, Sendable {

    case idle
    case rendering
    case complete
    case cancelled
    case failed

    var isBusy: Bool {
        self == .rendering
    }
}
