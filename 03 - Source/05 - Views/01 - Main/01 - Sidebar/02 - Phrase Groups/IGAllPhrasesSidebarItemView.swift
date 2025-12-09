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
    
    var body: some View {
        IGSidebarItem("All Phrases", systemImage: "tray.full", count: phrases.count)
    }
}
