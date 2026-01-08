//
//  IGDesignSettingsView.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-11-14.
//

import SwiftUI

struct IGDesignSettings: View {
    
    @Environment(IGAppSettings.self) private var settings
    @Environment(\.dismiss) private var dismiss
    
    @State private var tempConfig: IGDesignConfig
    private let designKey: IGDesignKey
    private let themes: [any IGTheme]
    
    init(_ designKey: IGDesignKey) {
        self.designKey = designKey
        self._tempConfig = State(initialValue: designKey.loadConfig())
        self.themes = designKey.themes
    }
    
    var body: some View {
        Section("\(designKey.displayName)") {
            TextField("Width", value: $tempConfig.width, format: .number)
                .textFieldStyle(.roundedBorder)
            TextField("Height", value: $tempConfig.height, format: .number)
                .textFieldStyle(.roundedBorder)
        }
        Section("Themes") {
            ForEach(themes, id: \.id) { theme in
                Toggle(theme.displayName, isOn: Binding(
                    get: {
                        tempConfig.activeThemeIDs.contains(theme.id)
                    },
                    set: { isOn in
                        if isOn {
                            tempConfig.activeThemeIDs.insert(theme.id)
                        } else {
                            tempConfig.activeThemeIDs.remove(theme.id)
                        }
                    }
                ))
            }
        }
        .onAppear{
            tempConfig = designKey.loadConfig()
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save", role: .confirm) {
                    settings.saveDesign(tempConfig, for: designKey)
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
    }
}

#Preview {
    @Previewable @State var settings: IGAppSettings = .init()
    
    IGDesignSettings(IGDesignKey.iHeartPhrase)
        .environment(settings)
}
