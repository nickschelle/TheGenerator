//
//  IGProcessState.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-11-XX.
//

import Foundation

enum IGProcessState: String, Codable, Equatable, Sendable {

    case idle
    case working
    case complete
    case cancelled
    case failed

    var isBusy: Bool {
        self == .working
    }
    
    var description: String {
        rawValue.capitalized
    }
    
    static let defaultValue: Self = .idle
    
    var symbol: String {
        switch self {
        case .idle: "circle"
        case .working: "hourglass.circle"
        case .complete: "checkmark.circle"
        case .cancelled: "xmark.circle"
        case .failed: "exclamationmark.circle"
        }
    }
}
