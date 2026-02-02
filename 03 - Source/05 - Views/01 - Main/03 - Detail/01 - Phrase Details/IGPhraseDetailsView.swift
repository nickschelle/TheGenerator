//
//  IGPhraseDetailsView.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-11-06.
//

import Foundation
import SwiftUI
import SwiftData

struct IGPhraseDetails: View {
    
    @Environment(IGAppModel.self) private var app
    @Environment(IGAppSettings.self) private var settings

    @Query private var customTagsLinks: [IGSourceTagLink]
    @Query private var records: [IGRecord]
    
    private let phrase: IGPhrase
    
    @State private var selectedTheme: String = ""
    @State private var tempValue: String = ""
    @State private var showingRenameAlert: Bool = false
    @State private var showingDuplicateAlert: Bool = false
    @State private var showingArchivedRecords: Bool = false
    
    init(_ phrase: IGPhrase) {
        self.phrase = phrase
        _customTagsLinks = Query(
            IGTagManager.associatedCustomTagsFilter(for: phrase)
        )
        let phraseID = phrase.id
        _records = Query(FetchDescriptor(predicate: #Predicate {
            $0.phrase?.id == phraseID
        }))
    }
    
    private var accocaitedTags: Set<IGTag> {
        let presetTags = IGTagManager.associatedPresetTags(
            for: phrase,
            with: settings
        )
        
        let customTags = customTagsLinks.compactMap(\.tag)
        
        var associatedTags = presetTags.union(customTags)
        
        if let designKey = settings.workspace.workspace.designKey {
            let theme = try? designKey.design.theme(rawValue: selectedTheme)
            associatedTags = associatedTags.union(designKey.presetTags(using: theme))
        }
        
        return IGTagManager.dedupeByPriority(associatedTags)
    }
    
    var body: some View {
        VStack {
            IGPhraseDetailHeader(phrase, selectedTheme: $selectedTheme)
                .padding(.top)
            Form() {
                Section {
                    IGRowButton(action: phrase.isEditable ? { showRenameAlert() } : nil) {
                        LabeledContent("Phrase") {
                            Text(phrase.value)
                        }
                    }
                    LabeledContent("Last Modified") {
                        Text(phrase.dateModified.displayString)
                    }
                    LabeledContent("Created") {
                        Text(phrase.dateModified.displayString)
                    }
                }
                Section {
                    VStack {
                        IGRowButton(action: {
                            app.activeSheet = .editPhraseTags(phrase, accocaitedTags)
                        }) {
                            Text("Tags")
                        }
                        IGTagList(accocaitedTags)
                    }
                }
                IGPhraseDetailRecordSection(phrase)
            }
            .formStyle(.grouped)
        }
        .onAppear(perform: syncThemeFromWorkspace)
        .onChange(of: settings.workspace.workspace.designKey, syncThemeFromWorkspace)
        .alert("Update Phrase", isPresented: $showingRenameAlert) {
            TextField("Phrase", text: $tempValue)
                .onChange(of: tempValue) { old, new in
                    if old != new {
                        tempValue = tempValue.titleCased
                    }
                }
            Button("Cancel", role: .cancel) { showingRenameAlert = false }
            Button("Update", action: performRename)
                .disabled(tempValue.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .alert("A tag with that name already exists.", isPresented: $showingDuplicateAlert) {
            Button("OK", role: .cancel) {
                showRenameAlert()
            }
        }
    }
    
    private func syncThemeFromWorkspace() {
        guard let rawTheme = settings.workspace.workspace.designKey?.defaultTheme.rawValue else {
            return
        }
        selectedTheme = rawTheme
    }
    
    private func performRename() {
        /*
        if try !IGPhraseManager.updatePhrase(phrase, value: tempValue, in: app.context) {
            showingDuplicateAlert = true
        }
         */
    }
    
    private func showRenameAlert() {
        tempValue = phrase.value
        showingRenameAlert = true
    }
}

#Preview {
    @Previewable @State var app: IGAppModel = .init()
    @Previewable @State var settings: IGAppSettings = .init()
    
        IGPhraseDetails(IGPhrase("Stinky Orange"))
            .frame(width: 400, height: 400)
            .environment(app)
            .environment(settings)
}
