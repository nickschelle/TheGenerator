//
//  IGMetadataSettingsView.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-11-14.
//

import SwiftUI

struct IGMetadataSettings: View {
    
    @Environment(IGAppModel.self) private var app
    @Environment(IGAppSettings.self) private var settings
    @Environment(\.dismiss) private var dismiss
    
    @State private var tempConfig: IGMetadataConfig = .load()
    
    var body: some View {
        Section("Image Metadata") {
            TextField("Author", text: $tempConfig.author)
                .textFieldStyle(.roundedBorder)
        }
        .onAppear{
            tempConfig = settings.metadata
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save", role: .confirm) {
                    settings.metadata = tempConfig
                    settings.saveMetadata()
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
    }
}

#Preview {
    @Previewable @State var app: IGAppModel = .init()
    @Previewable @State var settings: IGAppSettings = .init()
    
    IGMetadataSettings()
        .environment(app)
        .environment(settings)
}
