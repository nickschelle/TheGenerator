//
//  IHeartPhraseTheme.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-12-27.
//

import Foundation


enum IHeartPhraseTheme: String, IGDesignTheme, RawRepresentable {
    case classicWhite
    case classicBlack
    
    static var defaultTheme: Self {
        .classicWhite
    }

    var displayName: String {
        switch self {
        case .classicWhite: "Classic in White"
        case .classicBlack: "Classic in Black"
        }
    }
    
    var textColor: IGColor {
        switch self {
        case .classicWhite: .black
        case .classicBlack: .white
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
    
    var preferredBackground: IGBackgroundStyle {
        switch self {
        case .classicWhite: .light
        case .classicBlack: .dark
        }
    }
    
    @MainActor var presetTags: Set<IGTag> {[
        IGTag("\(heartColor.name.lowercased()) heart", scope: .theme, isPreset: true),
        IGTag("\(textColor.name.lowercased()) text", scope: .theme, isPreset: true),
        IGTag("\(textFont.displayName.lowercased()) font", scope: .theme, isPreset: true)
    ]}
}
