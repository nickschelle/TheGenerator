//
//  TheGeneratorApp.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-11-30.
//

import SwiftUI
import SwiftData

@main
struct TheGeneratorApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [
                    IHPhrase.self,
                    IHGroup.self,
                    IHGroupPhraseLink.self
                ])
        }
    }
}
