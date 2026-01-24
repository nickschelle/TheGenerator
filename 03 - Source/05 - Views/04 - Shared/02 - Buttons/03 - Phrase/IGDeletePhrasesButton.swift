//
//  IGDeletePhrasesButton.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-10-21.
//

import SwiftUI
import SwiftData

struct IGDeletePhrasesButton: View {
    
    @Environment(IGAppModel.self) private var app
    @Environment(IGAppSettings.self) private var settings
    
    private let phrase: IGPhrase?
    
    init(_ phrase: IGPhrase? = nil) {
        self.phrase = phrase
    }
    
    var deleteConfirmation: IGConfirmationContent {
        IGConfirmationContent(
            confirmTitle: "Delete", confirmRole: .destructive, message: {
                Text("Any linked Image Records will be deleted as well.")
            }
        )
    }
    
    var body: some View {
        IGModelActionButton(
            phrase,
            selection: app.selectedPhrases,
            actionTitle: "Delete",
            systemImage: "trash",
            confirmation: deleteConfirmation,
            action: delete
        )
    }
    
    private func delete(_ phrases: any Collection<IGPhrase>) {
        do {
            try IGPhraseManager.deletePhrases(phrases, with: settings, in: app.context)
            try app.context.save()
            if try IGTagManager.cleanOrphanTags(in: app.context) > 0 {
                try app.context.save()
            }
            app.selectedDetails = []
        } catch {
            app.appError = .phraseFailure("Failed to delete phrase: \(error)")
        }
    }
}

#Preview {
    
    @Previewable @State var app: IGAppModel = .init()
    
    IGDeletePhrasesButton()
        .environment(app)
}
