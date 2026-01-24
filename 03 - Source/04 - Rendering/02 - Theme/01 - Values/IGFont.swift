//
//  IGFont.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-10-18.
//

import Foundation

enum IGFont: String, Codable, CaseIterable, Identifiable, Sendable {
    
    case helveticaBold = "Helvetica-Bold"
    
    var id: String { rawValue }
    static var defaultValue: Self { .helveticaBold }
    
    var displayName: String {
        switch self {
        case .helveticaBold: "Helvetica Bold"
        }
    }
}
