//
//  IGDesignSettingsView.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-11-14.
//

import SwiftUI

struct IGDesignSettings: View {
    
    @Environment(IGAppModel.self) private var app
    @Environment(\.dismiss) private var dismiss
    
    @State private var tempConfig: IGDesignConfig
    
    private let design: IGDesignKey
    
    init(_ design: IGDesignKey) {
        self.design = design
        self._tempConfig = State(initialValue: design.loadConfig())
    }
    
    var body: some View {
        Section("\(design.displayName)") {
            TextField("Width", value: $tempConfig.width, format: .number)
                .textFieldStyle(.roundedBorder)
            TextField("Height", value: $tempConfig.height, format: .number)
                .textFieldStyle(.roundedBorder)
        }
        .onAppear{
            tempConfig = design.loadConfig()
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save", role: .confirm) {
                    design.saveConfig(tempConfig)
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
    }
}

#Preview {
    @Previewable @State var app: IGAppModel = .init()
    
    IGMetadataSettings()
        .environment(app)
}
