//
//  IGPhraseRowView.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-09-29.
//

import SwiftUI
import SwiftData

struct IGPhraseRow: View {
        
    @Environment(IGAppModel.self) private var app
    @Environment(IGAppSettings.self) private var settings
    
    @FocusState private var isFocused: Bool
    
    @State private var tempValue: String = ""
    @State private var isShowingDuplicateAlert: Bool = false
    
    private let phrase: IGPhrase?
    private let group: IGGroup?
    
    init(
        _ phrase: IGPhrase? = nil,
        group: IGGroup? = nil
    ) {
        self.phrase = phrase
        self.group = group
    }
    
    private var isEditing: Bool {
        guard let phraseToEdit = app.phraseToEdit else { return false }
        return phrase == phraseToEdit
    }

    private var isNewPhrase: Bool {
        phrase == nil
    }

    private var sortOrder: Int? {
        let groupID = group?.id
        return phrase?.groupLinks.filter { $0.group?.id == groupID }.first?.sortOrder
    }

    var body: some View {
        Group {
            if isNewPhrase || isEditing {
                IGContentRow("Phrase", systemImage: "heart.text.square") {
                    TextField("Something...", text: $tempValue)
                        .textFieldStyle(.plain)
                        .focused($isFocused)
                }
                .onChange(of: tempValue) { old, new in
                    let normalized = IGPhrase.normalizeForInput(new)
                    if normalized != new {
                        Task { @MainActor in
                            await Task.yield()
                            tempValue = normalized
                        }
                    }
                }
                .onAppear {
                    tempValue = phrase?.value ?? ""
                    DispatchQueue.main.async {
                        isFocused = true
                    }
                }
            } else {
                IGContentRow(
                    phrase?.value ?? "",//settings.image.template.format(phrase?.value ?? ""),
                    systemImage: "heart.text.square"
                ) /*{
                    
                    if let phrase {
                        IHFreshnessIndicators(for: phrase)
                    }
                     
                }
                   */
                .contextMenu {
                    IGEditPhraseButton(phrase)
                    IGPhraseGroupMenu(phrase)
                    IGEditTagsButton(phrase, selection: app.selectedPhrases)
                    IGDeletePhrasesButton(phrase)
                }
            }
        }
        .onChange(of: isFocused, commitPhrase)
        .onChange(of: isEditing, setFocus)
        .onSubmit(commitPhrase)
        .alert("A phrase with that name already exists.", isPresented: $isShowingDuplicateAlert) {
            Button("OK", role: .confirm) {
                DispatchQueue.main.async {
                    isFocused = true
                }
            }
        }
    }
    
    func setFocus() {
        if isEditing {
            isFocused = true
        }
    }

    func commitPhrase() {
       
        guard !isFocused else { return }
        app.isAddingPhrase = false
        
        guard !tempValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        do {
            if let phrase {
                if try !IGPhraseManager.updatePhrase(phrase, value: tempValue, in: app.context) {
                    isShowingDuplicateAlert = true
                    return
                }
            } else {
                let newPhrase = try IGPhraseManager.newPhrase(tempValue, in: app.context)
                if let group {
                    IGGroupManager.add([newPhrase], to: [group], in: app.context)
                }
            }
            
            try app.context.save()
            Task { @MainActor in
                await Task.yield()
                
                if phrase == nil {
                    app.isAddingPhrase = true
                    isFocused = true
                } else {
                    app.phraseToEdit = nil
                }
            }
        } catch {
            if phrase != nil {
                app.appError = .phraseFailure("Failed to update phrase: \(error.localizedDescription)")
            } else {
                app.appError = .phraseFailure("Failed to add phrase: \(error.localizedDescription)")
            }
        }
    }
}


#Preview {
    
    @Previewable @State var app: IGAppModel = .init()
    List {
        IGPhraseRow(
            IGPhrase("Cool Dudes")
        )
        IGPhraseRow(
            IGPhrase("Cool Dudes")
        )
        IGPhraseRow(
            IGPhrase("Cool Dudes")
        )
    }
    .environment(app)
}
