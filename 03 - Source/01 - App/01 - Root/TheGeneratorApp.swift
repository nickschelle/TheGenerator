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
    @State private var settings = IGAppSettings()
    
    var body: some Scene {
        Window("The Generator", id: "main") {
            MainView()
                .modelContainer(app.container)
                .environment(app)
                .environment(settings)
        }
        .windowResizability(.contentSize)
        .windowStyle(.titleBar)
        .defaultPosition(.center)
        .commands {
            // fill in later
        }
        
        Settings {
            IGSettingsView()
                .modelContainer(app.container)
                .environment(app)
                .environment(settings)
        }
        .windowResizability(.contentSize)
    }
}
