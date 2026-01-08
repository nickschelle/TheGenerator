//
//  IGAllPhrasesSidebarItemView.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-09-29.
//

import SwiftUI
import SwiftData

struct IGAllPhrasesSidebarItem: View {
    
    @Query var phrases: [IGPhrase]
    
    init(designKey: IGDesignKey? = nil) {
        if let rawKey = designKey?.rawValue {
            _phrases = Query(filter: #Predicate<IGPhrase> { phrase in
                phrase.designLinks.contains {
                    $0.rawDesignKey == rawKey
                }
            })
        } else {
            _phrases = Query()
        }
    }
    
    var body: some View {
        IGSidebarItem("All Phrases", systemImage: "tray.full", count: phrases.count)
    }
}
