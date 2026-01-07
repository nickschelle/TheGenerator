//
//  IGDefaultTagSettingsView.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-10-07.
//

import SwiftUI
import SwiftData

struct IGDefaultTagSettings: View {
    
    @Environment(IGAppModel.self) private var app
    @Environment(IGAppSettings.self) private var settings
    @Environment(\.dismiss) private var dismiss
    
    @State private var tempTags: Set<IGTempTag> = []

    private var presetTags: Set<IGTag> {
        settings.presetTags
    }
    
    var body: some View {
        Section("Global Tags") {
            IGTagEditor($tempTags, staticTags: presetTags, at: .defaults)
        }
        .onAppear {
            let rawScope = IGTagScope.defaults.rawValue

            let tags = (try? app.context.fetch(
                FetchDescriptor<IGTag>(
                    predicate: #Predicate { $0.rawScope == rawScope }
                )
            )) ?? []

            tempTags = Set(tags.map({ IGTempTag(from: $0, ignoring: IGTagScope.defaults.id) } ))
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save", role: .confirm) {
                     do {
                        if try IGTagManager.updateTags(to: tempTags, for: .defaults, in: app.context) {
                            settings.saveDefaultTags()
                            try app.context.save()
                            if try IGTagManager.cleanOrphanTags(in: app.context) > 0 {
                                try app.context.save()
                            }
                        }
                    } catch {
                        
                    }
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
    Form {
        IGDefaultTagSettings()
            .environment(app)
            .environment(settings)
    }
    .formStyle(.grouped)
}
