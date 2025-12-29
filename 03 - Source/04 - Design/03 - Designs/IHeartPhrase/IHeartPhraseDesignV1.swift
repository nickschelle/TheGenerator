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
    typealias Cache = IHeartPhraseCache
    
    static var name: String { "I ♥ Phrase" }
    static var version: Int { 1 }
    static var cache: Cache?
    
    static var presetTags: Set<IGTag> {
        [
            IGTag("I ♥", scope: .design, isPreset: true),
            IGTag("I Heart", scope: .design, isPreset: true),
            IGTag("I Love", scope: .design, isPreset: true),
        ]
    }
    
    static func format(_ phrase: String) -> String {
        "I ♥ \(phrase)"
    }
    
    static func drawLayout(
        phrase: String,
        theme: Theme,
        cache: Cache,
        in context: CGContext
    ) {
        
    }
}
