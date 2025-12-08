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
    
    @State private var app = IGAppModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(app.container)
                .environment(app)
        }
    }
}
