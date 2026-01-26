//
//  IGImageProcess.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-11-02.
//

import Foundation

enum IGImageProcess: String {
    case render
    case upload
    
    var displayText: String {
        rawValue.capitalized
    }

    var workingDescription: String {
        switch self {
        case .render: "Rendering…"
        case .upload: "Uploading…"
        }
    }
}
