//
//  IGPhraseGroupMenu.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-10-25.
//

import SwiftUI
import SwiftData

struct IGPhraseGroupMenu: View {
    
    @Environment(IGAppModel.self) private var app
    
    @Query(sort: [SortDescriptor(\IGGroup.name)]) private var groups: [IGGroup]
    
    private let phrase: IGPhrase?
    
    init(_ phrase: IGPhrase? = nil) {
        self.phrase = phrase
    }
    
    private var selection: Set<IGPhrase> {
        guard let phrase else { return app.selectedPhrases }
        return app.selectedPhrases.contains(phrase) ? app.selectedPhrases : [phrase]
    }
    
    var body: some View {
        Menu("Groups", systemImage: "rectangle.stack") {
            ForEach(groups) { group in
                let status: IGMatchStatus = IGMatchStatus.evaluate(selection: selection, in: group.phrases)
                Button(group.name, systemImage: status.systemImage) {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        updateSelected(status, with: group)
                    }
                }
            }
        }
    }
    
    private func updateSelected(_ status: IGMatchStatus, with group: IGGroup) {
        do {
            try withAnimation(.easeInOut(duration: 0.15)) {
                switch status {
                case .all:
                    try IGGroupManager.remove(
                        selection,
                        from: [group],
                        in: app.context
                    )
                case .some, .none:
                    IGGroupManager.add(
                        selection,
                        to: [group],
                        in: app.context
                    )
                }
            }

            try app.context.save()
        } catch {
            app.appError = .phraseFailure(
                "Failed to move phrases to/from group: \(error)"
            )
        }
    }
}

#Preview {
    
    @Previewable @State var app: IGAppModel = .init()
    
    IGPhraseGroupMenu()
        .environment(app)
}
