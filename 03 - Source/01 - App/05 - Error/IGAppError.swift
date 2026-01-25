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
    case tagFailure(String)
    case recordFailure(String)
    case renderFailure(String)
    case uploadFailure(String)

    var errorDescription: String? {
        switch self {
        case .groupFailure: "Group Failure Error"
        case .phraseFailure: "Phrase Failure Error"
        case .tagFailure: "Tag Failure Error"
        case .recordFailure: "Record Failure Error"
        case .renderFailure: "Render Failure Error"
        case .uploadFailure: "Upload Failure Error"
        }
    }

    var errorMessage: String? {
        switch self {
        case .groupFailure(let error): error
        case .phraseFailure(let error): error
        case .tagFailure(let error): error
        case .recordFailure(let error): error
        case .renderFailure(let error): error
        case .uploadFailure(let error): error
        }
    }
}
