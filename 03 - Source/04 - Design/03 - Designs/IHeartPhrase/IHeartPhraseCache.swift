//
//  IHeartPhraseCache.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-12-27.
//

import Foundation

struct IHeartPhraseCache: IGDesignCache {
    typealias Theme = IHeartPhraseTheme
    
    var size: CGSize
    var theme: Theme
    
    init(at size: CGSize, with theme: Theme) {
        self.size = size
        self.theme = theme
    }
    
}
