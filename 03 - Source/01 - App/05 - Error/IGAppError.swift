//
//  IGAppError.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-12-08.
//

import Foundation

enum IGAppError: LocalizedError, Identifiable {
    var id: String { localizedDescription }

    case groupFailure(String)
    case phraseFailure(String)

    var errorDescription: String? {
        switch self {
        case .groupFailure: "Group Error"
        case .phraseFailure: "Phrase Error"
        }
    }

    var errorMessage: String? {
        switch self {
        case .groupFailure(let error): error
        case .phraseFailure(let error): error
        }
    }
}
