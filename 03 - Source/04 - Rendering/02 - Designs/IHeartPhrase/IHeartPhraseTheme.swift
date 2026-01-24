//
//  IHeartPhraseTheme.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-12-27.
//

import Foundation


enum IHeartPhraseTheme: String, IGDesignTheme, RawRepresentable {
    case classicOnLight
    case classicOnDark
    
    static var defaultTheme: Self {
        .classicOnLight
    }

    var displayName: String {
        switch self {
        case .classicOnLight: "Classic for Light Backgrounds"
        case .classicOnDark: "Classic for Dark Backgrounds"
        }
    }
    
    var textColor: IGColor {
        switch self {
        case .classicOnLight: .black
        case .classicOnDark: .white
        }
    }
    
    var textFont: IGFont {
        switch self {
        default : .helveticaBold
        }
    }
    
    var heartColor: IGColor {
        switch self {
        default : .red
        }
    }
    
    @MainActor var presetTags: Set<IGTag> {
        let common: [IGTag] = [
            IGTag("Red Heart", scope: .theme, isPreset: true),
            IGTag("Helvetica", scope: .theme, isPreset: true)
        ]

        let textColor: IGTag = switch self {
        case .classicOnLight:
            IGTag("Black Text", scope: .theme, isPreset: true)
        case .classicOnDark:
            IGTag("White Text", scope: .theme, isPreset: true)
        }

        return Set(common + [textColor])
    }
}
