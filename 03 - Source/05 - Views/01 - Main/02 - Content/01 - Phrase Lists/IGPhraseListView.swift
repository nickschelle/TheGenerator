//
//  IGPhraseList.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-09-29.
//

import SwiftUI
import SwiftData

struct IGPhraseList: View {
    
    enum focusedType: Hashable {
        case phrase(IGPhrase)
        case newPhrase
    }
    
    @Environment(IGAppModel.self) private var app
    @Environment(IGAppSettings.self) private var settings
    
    @Namespace private var phraseFocusScope
    @FocusState private var focus: focusedType?
    @Query private var phrases: [IGPhrase]

    @State private var phraseToEdit: IGPhrase? = nil
    
    @State private var isShowingMenu: Bool = false
    
    private let group: IGGroup?
    
    init(for group: IGGroup?) {
        self.group = group
    }
    
    var descriptor: FetchDescriptor<IGPhrase> {

        // 1️⃣ Group + Design
        if let groupID = group?.id, let designKey = settings.workspace.workspace.designKey {
            return FetchDescriptor(
                predicate: #Predicate<IGPhrase> { phrase in
                    phrase.groupLinks.contains {
                        $0.group?.id == groupID
                    }
                    &&
                    phrase.designLinks.contains {
                        $0.rawDesignKey == designKey.rawValue
                    }
                },
                sortBy: []
            )
        }

        // 2️⃣ Group only
        if let groupID = group?.id {
            return FetchDescriptor(
                predicate: #Predicate<IGPhrase> { phrase in
                    phrase.groupLinks.contains {
                        $0.group?.id == groupID
                    }
                },
                sortBy: []
            )
        }

        // 3️⃣ Design only
        if let designKey = settings.workspace.workspace.designKey {
            return FetchDescriptor(
                predicate: #Predicate<IGPhrase> { phrase in
                    phrase.designLinks.contains {
                        $0.rawDesignKey == designKey.rawValue
                    }
                },
                sortBy: []
            )
        }

        // 4️⃣ No filters
        return FetchDescriptor(
            predicate: #Predicate<IGPhrase> { _ in true },
            sortBy: []
        )
    }
    
    var body: some View {
        @Bindable var app = app
        IGContentList(
            group?.name ?? "All Phrases",
            descriptor: descriptor,
            selection: $app.selectedDetails,
            forEachContent: { phrase in
                NavigationLink(value: IGDetailSelection.phrase(phrase) ) {
                    IGPhraseRow(phrase, group: group)
                        .focused($focus, equals: focusedType.phrase(phrase))
                }
                
            }, listContent: {
                if app.isAddingPhrase {
                    IGPhraseRow(group: group)
                        .focused($focus, equals: focusedType.newPhrase)
                }
            }
        )
        .navigationTitle(group?.name ?? "All Phrases")
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                IGNewPhraseButton()
                Menu("More", systemImage: "ellipsis") {
                    IGEditPhraseButton()
                    IGEditTagsButton(selection: app.selectedPhrases)
                    IGPhraseGroupMenu()
                    IGPasteButton()
                    IGDeletePhrasesButton()
                    Divider()
                    IGPhraseDesignMenu()
                    Divider()
                    //IHSelectAllPhrases()
                    Divider()
                    IGAddToRenderQueueButton()
                }
                .menuIndicator(.hidden)
            }
        }
        .focusScope(phraseFocusScope)
    }
}

#Preview {
    @Previewable @State var app: IGAppModel = .init()
    @Previewable @State var group: IGGroup? = nil
    
    IGPhraseList(for: group)
        .environment(app)
}
