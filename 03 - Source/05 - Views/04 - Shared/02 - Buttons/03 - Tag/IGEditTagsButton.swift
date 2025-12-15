//
//  IGEditTagsButton.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-12-15.
//

import SwiftUI
import SwiftData

struct IGEditTagsButton<T: IGTaggable & IGDateStampable>: View {
    @Environment(IGAppModel.self) private var app
    // @Environment(IGAppSettings.self) private var settings
    
    private let item: T?
    private let selection: Set<T>

    init(_ item: T? = nil, selection: Set<T>) {
        self.item = item
        self.selection = selection
    }
    
    var deleteConfirmation: IGConfirmationContent {
        IGConfirmationContent(
            confirmTitle: "Delete", confirmRole: .destructive, message: {
                Text("Any linked Image Records will be deleted as well.")
            }
        )
    }
    
    var body: some View {
        IGModelActionButton(
            item,
            selection: selection,
            systemImage: "trash",
            titleBuilder: { _ in
                "Edit Tags"
            },
            action: editTags,
            
        )
    }
    
    private func editTags(_ items: [T]) {
        let identity = Set(items.map{ $0.identity })
        app.activeSheet = .editTags(identity, onChange)
    }
    
    private func onChange() {
        do {
            for item in selection {
                item.touch()
            }
            try app.context.save()
        } catch {
            app.appError = .tagFailure("Failed to update save tagged items: \(error.localizedDescription)")
        }
        
    }
}

#Preview {
    IGEditTagsButton<IGGroup>(selection: [])
}
