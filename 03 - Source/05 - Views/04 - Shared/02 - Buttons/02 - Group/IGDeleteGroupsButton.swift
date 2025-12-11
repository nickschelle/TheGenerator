//
//  IGDeleteGroupsButton.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-10-21.
//

import SwiftUI
import SwiftData

struct IGDeleteGroupsButton: View {
    @Environment(IGAppModel.self) private var app
    
    private let group: IGGroup?
    
    init(_ group: IGGroup? = nil) {
        self.group = group
    }
    
    var deleteConfirmation: IGConfirmationContent {
        IGConfirmationContent(
            confirmTitle: "Delete", confirmRole: .destructive, message: {
                Text("Phrases will remain in 'All Phrases' and other Groups they belong to.")
            }
        )
    }
    
    var body: some View {
        IGModelActionButton(
            group,
            selection: app.selectedGroups,
            actionTitle: "Delete",
            systemImage: "trash",
            confirmation: deleteConfirmation,
            action: delete
        )
    }
    
    private func delete(_ groups: [IGGroup]) {
        do {
            try IGGroupManager.deleteGroups(groups, in: app.context)
            try app.context.save()
            if try IGTagManager.cleanOrphanTags(in: app.context) > 0 {
                try app.context.save()
            }
            app.selectedContents = [.allPhrases]
        } catch {
            app.appError = .groupFailure("Failed to delete group: \(error)")
        }
    }
}

#Preview {
    
    @Previewable @State var app: IGAppModel = .init()
    
    IGDeleteGroupsButton()
        .environment(app)
}
