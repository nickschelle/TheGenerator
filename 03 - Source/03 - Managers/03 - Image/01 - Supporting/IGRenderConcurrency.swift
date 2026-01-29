//
//  IGRenderConcurrency.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2026-01-28.
//


enum IGRenderConcurrency: String, Codable, CaseIterable, Identifiable {
    case automatic
    case conservative
    case aggressive
    case custom

    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .automatic:
            return "Automatic"
        case .conservative:
            return "Conservative"
        case .aggressive:
            return "Aggressive"
        case .custom:
            return "Custom"
        }
    }
    
    var isCustom: Bool {
        self == .custom
    }

    func resolve(processorCount: Int, customValue: Int? = nil) -> Int {
        switch self {
        case .automatic:
            return max(2, processorCount - 1)

        case .conservative:
            return max(1, processorCount / 2)

        case .aggressive:
            return max(2, processorCount)

        case .custom:
            return max(1, min(customValue ?? 1, processorCount))
        }
    }
}
