//
//  IGPhraseDesignMenu.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2026-01-08.
//

import SwiftUI
import SwiftData

struct IGPhraseDesignMenu: View {
    
    @Environment(IGAppModel.self) private var app
    
    private let phrase: IGPhrase?
    
    init(_ phrase: IGPhrase? = nil) {
        self.phrase = phrase
    }
    
    private var selection: Set<IGPhrase> {
        guard let phrase else { return app.selectedPhrases }
        return app.selectedPhrases.contains(phrase) ? app.selectedPhrases : [phrase]
    }
    
    var designs: [IGDesignKey] {
        IGDesignKey.allCases
    }
    
    var body: some View {
        if selection.isEmpty {
            Button("Designs", systemImage: "rectangle.3.group", action: {}).disabled(true)
        } else {
            Menu("Designs", systemImage: "rectangle.3.group") {
                ForEach(designs) { designKey in
                    let phrasesWithDesign: [IGPhrase] = selection.filter { phrase in
                        phrase.designLinks.contains { link in
                            link.designKey == designKey
                        }
                    }
                    let status: IGMatchStatus = IGMatchStatus.evaluate(selection: selection, in: phrasesWithDesign)
                    Button(designKey.displayName, systemImage: status.systemImage) {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            updateSelected(status, with: designKey)
                        }
                    }
                    
                }
            }
        }
    }
    
    private func updateSelected(_ status: IGMatchStatus, with key: IGDesignKey) {
        do {
            withAnimation(.easeInOut(duration: 0.15)) {
                switch status {
                case .all:
                    key.disconnect(selection, in: app.context)
                case .some, .none:
                    key.connect(
                        selection,
                        in: app.context
                    )
                }
            }

            try app.context.save()
        } catch {
            app.appError = .phraseFailure(
                "Failed to connect/disconnect phrases to/from Design: \(error)"
            )
        }
    }
}
