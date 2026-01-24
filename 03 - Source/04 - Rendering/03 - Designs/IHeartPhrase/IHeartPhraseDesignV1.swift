//
//  IHeartPhraseDesign.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-12-27.
//

import Foundation
import Cocoa

enum IHeartPhraseDesignV1: IGDesign {
 
    typealias Theme = IHeartPhraseTheme
    
    static let baseName: String = "I ♥ Phrase"
    static let designVersion: Int = 1
   
    static var presetTags: Set<IGTag> {
        [
            IGTag("I ♥", scope: .design, isPreset: true),
            IGTag("I Heart", scope: .design, isPreset: true),
            IGTag("I Love", scope: .design, isPreset: true),
        ]
    }
    
    static func displayText(for phrase: String) -> String {
        "I ♥ \(phrase)"
    }
    
    static func drawLayout(
        of phrase: String,
        with theme: Theme,
        into context: CGContext
    ) {
        
    }
}

