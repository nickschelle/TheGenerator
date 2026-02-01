//
//  IGPhraseTagEditorSheet.swift.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-10-07.
//

import SwiftUI
import SwiftData

struct IGPhraseTagEditor: View {
    
    @Environment(IGAppModel.self) private var app
    @Environment(IGAppSettings.self) private var settings
    @Environment(\.dismiss) private var dismiss
    
    @State private var tempTags: Set<IGTempTag> = []
    @State private var staticTags: Set<IGTag> = []
    private let tags: Set<IGTag>
    private let phrase: IGPhrase
    
    init(for phrase: IGPhrase, tags: Set<IGTag>) {
        self.tags = tags
        self.phrase = phrase
    }
    
    var body: some View {
        Form {
            Section("'\(phrase.value)' Tags") {
                IGTagEditor($tempTags, staticTags: staticTags, for: phrase)
            }
            
        }
        .formStyle(.grouped)
        .onAppear {
            let phraseTags = tags.filter{ $0.scope == .phrase && !$0.isPreset}
            staticTags = tags.filter{ !phraseTags.contains($0) }
            tempTags = Set(phraseTags.map({ IGTempTag(from: $0, ignoring: phrase.id) } ))
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
                        if try IGTagManager.updateTags(to: tempTags, for: phrase, in: app.context) {
                            phrase.touch()
                        }
                        try app.context.save()
                        dismiss()
                    } catch {
                        app.appError = .tagFailure("Failed to update tags for phrase: \(error.localizedDescription)")
                    }
                    
                }
                .keyboardShortcut(.defaultAction)
            }
        }
    }
}

#Preview {
    @Previewable @State var app: IGAppModel = .init()
    @Previewable @State var settings: IGAppSettings = .init()
    
    IGPhraseTagEditor(for: IGPhrase("Jim"), tags: [
        IGTag("Cool Dude", scope: .phrase),
        IGTag("Poop", isPreset: true),
        IGTag("shine", scope: .phrase, isPreset: true)
    ])
        .environment(app)
        .environment(settings)
}
