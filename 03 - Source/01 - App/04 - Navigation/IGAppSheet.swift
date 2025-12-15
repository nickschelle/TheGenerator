//
//  IGAppSheet.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-10-10.
//

import SwiftUI

enum IGAppSheet: Identifiable {
    case newGroup
    case editGroup(IGGroup?)
    case ftpSignIn
    case editPhraseTags(IGPhrase, Set<IGTag>)
    case editTags(Set<IGTaggableIdentity>, () -> Void)

    var id: String {
        switch self {
        case .newGroup: "newGroup"
        case .editGroup(let group): "editGroup-\(group?.id.uuidString ?? "")"
        case .ftpSignIn: "ftpSignIn"
        case .editPhraseTags(let phrase, _): "editPhraseTags-\(phrase.id.uuidString)"
        case .editTags: "editTags"
        }
    }

    /// Provides the appropriate view for each case.
    @ViewBuilder
    var view: some View {
        switch self {
        case .newGroup: EmptyView()
            IGGroupInfoSheet()
        case .editGroup(let group):
            IGGroupInfoSheet(group)
        case .editTags(let selected, let onChange): IGBatchTagEditorSheet(selected, onChange: onChange)
        case .ftpSignIn: EmptyView()
            /*
            Form {
                IGFTPSignInSettings()
            }
            .formStyle(.grouped)
             */
        case .editPhraseTags://(let phrase, let tags):
            EmptyView()
            //IGPhraseTagEditor(for: phrase, tags: tags)
        }
        
    }
}

