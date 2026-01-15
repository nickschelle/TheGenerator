//
//  IGAddToRenderQueueButton.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-10-27.
//

import SwiftUI
import SwiftData

struct IGAddToRenderQueueButton: View {
    
    @Environment(IGAppModel.self) private var app
    @Environment(IGAppSettings.self) private var settings
    
    private var phrase: IGPhrase?
    
    init(_ phrase: IGPhrase? = nil) {
        self.phrase = phrase
    }
    
    var body: some View {
        IGModelActionButton(
            phrase,
            selection: app.selectedPhrases,
            systemImage: "photo.stack",
            titleBuilder: {
                "Add \($0) to Render Queue"
            },
            action: addToRender
        )
    }
    
    private func addToRender(_ selection: any Collection<IGPhrase>) {
        do {
            try IGRecordManager.createPhraseRecords(for: selection, with: settings, in: app.context)
            try app.context.save()
        } catch {
            app.appError = .recordFailure("Failed to add phrase to render queue: \(error.localizedDescription)")
        }
    }
}
