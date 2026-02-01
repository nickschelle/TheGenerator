//
//  IGBackgroundStyle.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2026-01-31.
//
import Foundation
import SwiftUI

enum IGBackgroundStyle {
    case light
    case dark
    
    @MainActor
    var backgroundColor: Color {
        switch self {
        case .light: return .white
        case .dark: return .black
        }
    }
}
