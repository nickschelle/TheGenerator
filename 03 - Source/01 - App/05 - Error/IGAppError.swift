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

    var errorDescription: String? {
        switch self {
        case .groupFailure: "Group Error"
        }
    }

    var errorMessage: String? {
        switch self {
        case .groupFailure(let error): error
        }
    }
}
