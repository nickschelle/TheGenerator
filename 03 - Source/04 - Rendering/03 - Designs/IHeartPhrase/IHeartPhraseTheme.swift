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
        case .classicOnLight:
            return "Classic for Light Backgrounds"
        case .classicOnDark:
            return "Classic for Dark Backgrounds"
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
