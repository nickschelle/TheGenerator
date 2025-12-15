//
//  IGEditPhraseButton.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-10-22.
//

import SwiftUI

struct IGEditPhraseButton: View {
    
    @Environment(IGAppModel.self) private var app
    
    let phrase: IGPhrase?
    
    init(_ phrase: IGPhrase? = nil) {
        self.phrase = phrase
    }
    
    var body: some View {
        IGModelActionButton(
            phrase,
            selected: app.selectedPhrase,
            actionTitle: "Edit",
            systemImage: "pencil",
            action: editPhrase
        )
    }
    
    func editPhrase(_ phrase: IGPhrase) {
        app.phraseToEdit = phrase
    }
}

#Preview {
    
    @Previewable @State var app: IGAppModel = .init()
    
    IGEditPhraseButton(IGPhrase("Poop"))
        .environment(app)
}
