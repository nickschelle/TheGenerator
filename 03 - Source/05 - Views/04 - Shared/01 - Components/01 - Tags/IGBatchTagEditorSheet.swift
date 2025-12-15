//
//  IGBatchTagEditorSheet.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-12-15.
//

import SwiftUI
import SwiftData

struct IGBatchTagEditorSheet: View {
    
    @Environment(IGAppModel.self) private var app
    @Environment(\.dismiss) private var dismiss

    @State private var tempTags: Set<IGTempTag> = []

    private let selection: Set<IGTaggableIdentity>
    private let scope: IGTagScope
    private let onChange: () -> Void

    init(_ selection: Set<IGTaggableIdentity>, onChange: @escaping () -> Void) {
        self.selection = selection

        guard let scope = selection.first?.tagScope else {
            fatalError("IGTaggableIdentity selection must not be empty")
        }

        self.scope = scope
        self.onChange = onChange
    }
    
    var body: some View {
        Form {
            IGTagEditor($tempTags, at: scope)
        }
        .formStyle(.grouped)
        .onAppear {
            do {
                let sourceTags = try app.context.tags(for: selection)
                tempTags = Set( sourceTags.map{ IGTempTag(from: $0, evalutating: Set(selection.map(\.id))) })
            } catch {
                app.appError = .groupFailure("Failed to fetch group tags: \(error.localizedDescription)")
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save", role: .confirm, action: updateSelection)
                    .keyboardShortcut(.defaultAction)
            }
        }
    }
    
    private func updateSelection() {
        do {
            
            if try IGTagManager.updateTags(using: tempTags, for: selection, in: app.context) {
                onChange()
            }
            
            try app.context.save()
            if try IGTagManager.cleanOrphanTags(in: app.context) > 0 {
                try app.context.save()
            }
            dismiss()
            
        } catch {
            app.appError = .tagFailure("Failed to update tags: \(error.localizedDescription)")
        }
    }
}

#Preview {
    IGBatchTagEditorSheet([], onChange: { })
}
