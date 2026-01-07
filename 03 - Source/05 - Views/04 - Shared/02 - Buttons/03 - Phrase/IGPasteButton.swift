//
//  IGPasteButton.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-11-20.
//

import SwiftUI
import SwiftData

struct IGPasteButton: View {
    
    @Environment(IGAppModel.self) private var app
    @State private var content: [String] = []
    @State private var isShowingPastedAlert: Bool = false
    
    var body: some View {
        Button("Paste Phrases", systemImage: "document.on.clipboard", action: attemptPaste)
            .alert("(content.count) phrasess added", isPresented: $isShowingPastedAlert) {
                Button("OK", role:.confirm, action: {})
            }
    }
    
    private func attemptPaste() {
        guard let pasteboardString = NSPasteboard.general.string(forType: .string) else {
            print("Nothing to paste")
            return
        }

        content = parsePastedPhrases(pasteboardString)

        guard !content.isEmpty else {
            print("No valid phrases found")
            return
        }
        
        let confirmation = IGConfirmationContent(
            "Paste \(content.count) phrases?",
            confirmTitle: "Paste", confirmRole: .confirm, onConfirm: {  pastePhrases(content) }
        )
        
        app.showConfirmation(confirmation)
        
    }
    
    private func pastePhrases(_ phraseValues: [String]) {
        guard !phraseValues.isEmpty else { return }

        // Snapshot selection to avoid mutation during paste
        let groups = Array(app.selectedGroups)

        do {
            let phrases = try phraseValues.map {
                try IGPhraseManager.newPhrase($0, in: app.context)
            }

            if !groups.isEmpty {
                IGGroupManager.add(phrases, to: groups, in: app.context)
            }

            try app.context.save()
            isShowingPastedAlert = true
        } catch {
            app.appError = .phraseFailure(
                "Failed to paste \(phraseValues.count) phrase(s): \(error)"
            )
        }
    }
    
    
    private func parsePastedPhrases(_ text: String) -> [String] {
        text
            .replacingOccurrences(of: "\t", with: "\n")   // Excel cells
            .replacingOccurrences(of: ",", with: "\n")    // comma lists
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
}

#Preview {
    IGPasteButton()
}
