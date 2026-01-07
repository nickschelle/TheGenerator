//
//  IGWorkspaceMenu.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2026-01-05.
//


import SwiftUI
import SwiftData

struct IGWorkspaceMenu: View {
    
    @Environment(IGAppSettings.self) private var settings
    
    var body: some View {
        @Bindable var settings = settings
        Picker("Workspace", systemImage: "folder", selection: $settings.workspace.workspace) {
            Text("Library").tag(IGWorkspaceConfig.Workspace.library)
            ForEach(IGDesignKey.allCases) { key in
                Text(key.displayName).tag(IGWorkspaceConfig.Workspace.design(key))
            }
        }
        .labelStyle(.titleAndIcon)
        .onChange(of: settings.workspace.workspace) {
            settings.saveWorkspace()
        }
    }
}

#Preview {
    
    @Previewable @State var settings: IGAppSettings = .init()
    
    IGPhraseGroupMenu()
        .environment(settings)
}
