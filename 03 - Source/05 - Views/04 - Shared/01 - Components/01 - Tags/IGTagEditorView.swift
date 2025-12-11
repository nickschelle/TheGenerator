//
//  IGTagEditorView.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-10-10.
//

import SwiftUI
import SwiftData

struct IGTagEditor: View {
    
    @Environment(IGAppModel.self) private var app
    //@Environment(IGAppSettings.self) private var settings
    
    @Binding private var selectionTags: Set<IGTempTag>
    @State private var scopeTags: Set<IGTempTag> = []

    @State private var tempValue: String = ""
    @State private var isShowingEditAlert: Bool = false
    @State private var tagToEdit: IGTempTag?
    
    private let staticTags: [IGTempTag]
    private let scope: IGTagScope
    private let sourceID: UUID
    
    init(
        _ selectionTags: Binding<Set<IGTempTag>>,
        staticTags: any Collection<IGTag> = [],
        for source: any IGTaggable
    ) {
        _selectionTags = selectionTags
        self.staticTags = staticTags.map { IGTempTag(from: $0, ignoring: source.id) }
        self.scope = type(of: source).tagScope
        self.sourceID = source.id
    }
    
    init(
        _ selectionTags: Binding<Set<IGTempTag>>,
        staticTags: any Collection<IGTag> = [],
        at scope: IGTagScope
    ) {
        _selectionTags = selectionTags
        self.staticTags = staticTags.map { IGTempTag(from: $0, ignoring: scope.id) }
        self.scope = scope
        self.sourceID = scope.id
    }
    
    private var availableTags: Set<IGTempTag> {
        scopeTags.subtracting(selectionTags)
    }

    var body: some View {
        VStack {
            IGTagList(
                selectionTags,
                static: staticTags,
                onCreateTag: createTag,
                addButtonColor: scope.color,
                onAction: handleTagAction,
                onEdit: promptEdit,
                onDelete: confirmDelete
            )
            if !availableTags.isEmpty {
                Divider()
                IGTagList(
                    availableTags,
                    onAction: handleTagAction,
                    onEdit: promptEdit,
                    onDelete: confirmDelete
                )
            }
        }
        .onAppear {
            let rawScope = self.scope.rawValue
            let description = FetchDescriptor(predicate: #Predicate<IGTag> {
                $0.rawScope == rawScope
            },
            sortBy: [SortDescriptor(\.value)])
            let tags = (try? app.context.fetch(description)) ?? []
            scopeTags = Set(tags.map { IGTempTag(from: $0, ignoring: sourceID)})
        }
        .alert("Edit Tag", isPresented: $isShowingEditAlert, presenting: tagToEdit) { tag in
            TextField("", text: $tempValue)
                .onChange(of: tempValue) { old, new in
                    let normalized = IGPhrase.normalizeForInput(new)
                    if normalized != new {
                        Task { @MainActor in
                            await Task.yield()
                            tempValue = normalized
                        }
                    }
                }
            Button("Cancel", role: .cancel) { tempValue = "" }
            Button("Rename", action: { performEdit(tag) })
                .disabled(tempValue.trimmingCharacters(in: .whitespaces).isEmpty)
        } message: { tag in
            let linkedCount = tag.linkCount
            if linkedCount > 0 {
                let modelName = linkedCount == 1 ? scope.display : scope.display.pluralized()
                Text("'\(tag.value)' is used by \(linkedCount) other \(modelName). Updating it will change it everywhere.")
            } else {
                EmptyView()
            }
            
        }
    }
    
    private func createTag(_ value: String) {
        let normalized = IGTag.normalizeForSave(value)
        guard !normalized.isEmpty else { return }

        let tag: IGTempTag
        if let existing = (selectionTags.union(scopeTags)).first(where: { $0.value == normalized }) {
            tag = existing
        } else {
            tag = IGTempTag(normalized, scope: scope)
        }

        _ = withAnimation { selectionTags.insert(tag) }
    }
    
    
    private func handleTagAction(_ tag: IGTempTag, action: IGTagActionType) {
        withAnimation {
            switch action {
            case .add:
                selectionTags.insert(tag)
            case .remove:
                selectionTags.remove(tag)
            case .delete:
                selectionTags.remove(tag)
                scopeTags.remove(tag)
            }
        }
    }

    private func confirmDelete(_ tag: IGTempTag) {
        if tag.isShared {
            tagToEdit = tag
            let linkedCount = tag.linkCount
            let modelName = linkedCount == 1 ? scope.display : scope.display.pluralized()
            app.showConfirmation(IGConfirmationContent(
                "Delete Tag?",
                confirmTitle: "Delete",
                confirmRole: .destructive,
                onConfirm: {  performDelete(tag)  },
                message: {
                    Text("Deleting '\(tag.value)' will also remove it from \(linkedCount) other \(modelName).")
                }
            ))
        } else {
            performDelete(tag)
        }
    }
 
    private func performDelete(_ tempTag: IGTempTag) {
        
        do {
            let tag = try tempTag.getTag(in: app.context)
            try IGTagManager.remove(tag, in: app.context)
            try app.context.save()

            let removed = try IGTagManager.cleanOrphanTags(in: app.context)
            if removed > 0 {
                try app.context.save()
            }

            selectionTags.remove(tempTag)
            scopeTags.remove(tempTag)

        } catch {
            app.appError = .tagFailure("Failed to delete tag: \(error.localizedDescription)")
        }
        
    }

    private func promptEdit(_ tag: IGTempTag) {
        tempValue = tag.value
        tagToEdit = tag
        isShowingEditAlert = true
    }
    
    private func performEdit(_ originalTempTag: IGTempTag) {
        defer { tagToEdit = nil }
        let oldValue = originalTempTag.value
        let newValue = tempValue.trimmingCharacters(in: .whitespaces)
        guard newValue != oldValue else { return }

        let updatedTempTag: IGTempTag
        do {
            let modelTag = try originalTempTag.getTag(in: app.context)
            let updatedModelTag = try IGTagManager.update(modelTag, to: newValue, in: app.context)
            updatedTempTag = IGTempTag(from: updatedModelTag, ignoring: sourceID)
        } catch {
            app.appError = .tagFailure("Failed to edit tag: \(error.localizedDescription)")
            return
        }

        func replace(_ old: IGTempTag, with new: IGTempTag, in set: inout Set<IGTempTag>) {
            if set.contains(old) {
                set.remove(old)
                set.insert(new)
            }
        }

        replace(originalTempTag, with: updatedTempTag, in: &selectionTags)
        replace(originalTempTag, with: updatedTempTag, in: &scopeTags)
        do {
            try app.context.save()
        } catch {
            app.appError = .tagFailure("Failed to save updated tag: \(error.localizedDescription)")
        }
    }
}

#Preview {
    @Previewable @State var app: IGAppModel = .init()
    //@Previewable @State var settings: IHAppSettings = .init()
    @Previewable @State var selection: Set<IGTempTag> = [
        IGTempTag("Travel", scope: .group,),
        IGTempTag("Food", scope: .group),
        IGTempTag("Work", scope: .group)
    ]
    
    let staticTags: Set<IGTag> = [
        IGTag("Other", scope: .defaults,),
        IGTag("Poop", scope: .phrase),
        IGTag("Stinky", scope: .defaults, isPreset: true)
    ]
    
    Form {
        IGTagEditor(
            $selection,
            staticTags: staticTags,
            at: .group
        )
            .environment(app)
            //.environment(settings)
    }
    .formStyle(.grouped)
}
