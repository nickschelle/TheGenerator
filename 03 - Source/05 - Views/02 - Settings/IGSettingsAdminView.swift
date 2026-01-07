//
//  IGSettingsAdminView.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-11-25.
//

import SwiftUI
import SwiftData

struct IGSettingsAdmin: View {
    
    @Environment(IGAppModel.self) private var app
    @Environment(IGAppSettings.self) private var settings
    @State private var isShowingAdmin: Bool = false
    
    @State private var isShowingResetConfirmation: Bool = false
    @State private var settingsResult: Result<String, Error>?
    @State private var isShowingSettingsResultAlert = false
    
    @State private var isShowingFormatConfirmation = false
    @State private var confirmationText = ""
    private let confirmationPhrase = "FORMAT"
    @State private var result: Result<String, Error>?
    @State private var isShowingFormatResultAlert: Bool = false
    
    var body: some View {
        Section("Admin") {
            Toggle("Show Admim Settings", isOn: $isShowingAdmin)
            if isShowingAdmin {
                HStack() {
                    Text("Settings")
                    Spacer()
                    Button("Reset", systemImage: "gearshape.arrow.trianglehead.2.clockwise.rotate.90", role: .destructive, action: {
                        isShowingResetConfirmation = true
                    })
                    .glassEffect(.clear.tint(.red.opacity(0.25)))
                }
                .confirmationDialog(
                    "Reset Settings",
                    isPresented: $isShowingResetConfirmation
                ) {
                    Button("Reset", role: .destructive) {
                        resetSettingsToDefaults()
                    }

                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text("Are you sure you want to reset all settings to their default values?")
                }
                
                HStack() {
                    Text("Library")
                    Spacer()
                    Button("Format Library", systemImage: "trash", role: .destructive, action: {
                        confirmationText = ""
                        isShowingFormatConfirmation = true
                    })
                    .glassEffect(.clear.tint(.red.opacity(0.25)))
                }
                .alert(
                    "Format Library",
                    isPresented: $isShowingFormatConfirmation
                ) {
                    TextField("Type \(confirmationPhrase)", text: $confirmationText)

                    Button("Format", role: .destructive) {
                        formatDatabase()
                        confirmationText = ""
                    }
                    .disabled(confirmationText != confirmationPhrase)

                    Button("Cancel", role: .cancel) {
                        confirmationText = ""
                    }
                } message: {
                    Text("""
                    Are you sure you want to format the entire library?

                    This will erase all phrases, groups, tags, and records.
                    This can’t be reversed.

                    To proceed, type “\(confirmationPhrase)”.
                    """)
                }
            }
        }
        .animation(.default, value: isShowingAdmin)
        .alert("Library Format", isPresented: $isShowingFormatResultAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            if let result {
                switch result {
                case .success(let message):
                    Text("Success: \(message)")
                case .failure(let error):
                    Text("Failed: \(error.localizedDescription)")
                }
            } else {
                Text("Unknown result.")
            }
        }
        .alert("Settings Reset", isPresented: $isShowingSettingsResultAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            if let settingsResult {
                switch settingsResult {
                case .success(let message):
                    Text("Success: \(message)")
                case .failure(let error):
                    Text("Failed: \(error.localizedDescription)")
                }
            } else {
                Text("Unknown result.")
            }
        }
    }
       
    
    func formatDatabase() {
        result = IGModelContainerManager.eraseAllModels(in: app.context)
        isShowingFormatResultAlert = true
    }
    
    private func resetSettingsToDefaults() {

        do {
            let settingsTags = try app.context.tags(at: .defaults)
            for tag in settingsTags {
                app.context.delete(tag)
            }
            try app.context.save()
            
            // Reset UserDefaults-backed settings
            settings.resetSettings()

            settingsResult = .success("All settings were reset to their default values.")
        } catch {
            settingsResult = .failure(error)
        }

        isShowingSettingsResultAlert = true
    }
    
}

#Preview {
    IGSettingsAdmin()
}
