//
//  IGTagListView.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-09-24.
//

import SwiftUI

struct IGTagList: View {

    private let tags: [IGTempTag]
    private let staticTags: [IGTempTag]
    private let onAction: ((IGTempTag, IGTagActionType) -> Void)?
    private let onEdit: ((IGTempTag) -> Void)?
    private let onDelete: ((IGTempTag) -> Void)?
    private let onCreateTag: ((String) -> Void)?
    private let addButtonColor: Color


    init<T: Collection<IGTempTag>, U: Collection<IGTempTag>>(
        _ tags: T,
        static staticTags: U = []
    ) {
        self.tags = Array(tags)
        self.staticTags = Array(staticTags)
        self.onAction = nil
        self.onEdit = nil
        self.onDelete = nil
        self.onCreateTag = nil
        self.addButtonColor = .accentColor
    }
    
    init<T: Collection<IGTag>, U: Collection<IGTag>>(
        _ tags: T,
        static staticTags: U = []
    ) {
        self.tags = tags.map { IGTempTag(from: $0) }
        self.staticTags = staticTags.map { IGTempTag(from: $0) }
        self.onAction = nil
        self.onEdit = nil
        self.onDelete = nil
        self.onCreateTag = nil
        self.addButtonColor = .accentColor
    }

    init<T: Collection<IGTempTag>, U: Collection<IGTempTag>>(
        _ tags: T,
        static staticTags: U = [],
        onCreateTag: ((String) -> Void)? = nil,
        addButtonColor: Color = .accentColor,
        onAction: @escaping (IGTempTag, IGTagActionType) -> Void,
        onEdit: ((IGTempTag) -> Void)? = nil,
        onDelete: ((IGTempTag) -> Void)? = nil
    ) {
        self.tags = Array(tags)
        self.staticTags = Array(staticTags)
        self.onCreateTag = onCreateTag
        self.addButtonColor = addButtonColor
        self.onAction = onAction
        self.onEdit = onEdit
        self.onDelete = onDelete
    }

    private var combinedTags: [IGTempTag] {
        let filtetedStatic = staticTags.filter {tag in !tags.contains{ tag.value == $0.value } }
        let combined = tags + filtetedStatic
        let cleaned = IGTagManager.dedupeByPriority(combined)
        return IGTagManager.sortTempTags(cleaned)
    }

    var body: some View {
        WrappingHStack(
            alignment: .topLeading,
            horizontalSpacing: 6,
            verticalSpacing: 8
        ) {
            ForEach(combinedTags) { tag in
                if let action = onAction, !staticTags.contains(tag), !tag.isPreset {
                    let mode = IGTagActionType.resolve(for: tag, isRemoving: (onCreateTag != nil))
                    Button { action(tag, mode) } label: {
                        IGTagView(
                            tag.value,
                            in: tag.scope.color.opacity(tag.isPartiallyApplied ? 0.5 : 1.0),
                            isPreset: tag.isPreset,
                            actionType:  mode
                        )
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        if let onEdit { Button("Edit Tag", systemImage: "pencil") { onEdit(tag) } }
                        if let onDelete { Button("Delete Tag", systemImage: "trash") { onDelete(tag) } }
                    }

                } else {
                    IGTagView(tag.value, in: tag.scope.color, isPreset: tag.isPreset)
                }
            }

            // Add button appears ONLY when in create/edit mode.
            if let onCreateTag, onAction != nil {
                IGAddTagButton(color: addButtonColor, onAddTag: onCreateTag)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 40)
    }
}
