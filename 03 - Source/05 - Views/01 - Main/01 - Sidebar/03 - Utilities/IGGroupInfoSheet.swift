//
//  IGGroupInfoSheet.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-09-22.
//

import SwiftUI
import SwiftData

struct IGGroupInfoSheet: View {

    @Environment(IGAppModel.self) private var app
    @Environment(IGAppSettings.self) private var settings
    @Environment(\.dismiss) private var dismiss

    @State private var isShowingDuplicateAlert = false
    @State private var tempName: String = ""
    @State private var tempTags: Set<IGTempTag> = []

    private let group: IGGroup?

    init(
        _ group: IGGroup? = nil
    ) {
        self.group = group
    }
    
    var tempGroup: IGGroup {
        IGGroup(tempName)
    }

    var presetTags: Set<IGTag> {
        tempName.isEmpty ? [] : tempGroup.presetTags
    }

    // MARK: - Body

    var body: some View {
        Form {
            Section(group != nil ? "Edit Group" : "New Group") {
                TextField("Name", text: $tempName)
                    .textFieldStyle(.roundedBorder)
                    .disableAutocorrection(true)
                    .onChange(of: tempName) { old, new in
                        let normalized = IGGroup.normalizeForInput(new)
                        if normalized != new {
                            tempName = normalized
                        }
                    }
                IGTagEditor($tempTags, staticTags: presetTags, for: tempGroup)
            }
        }
        .formStyle(.grouped)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save", role: .confirm, action: saveGroup)
                    .keyboardShortcut(.defaultAction)
            }
        }
        .onAppear {
            if let group {
                tempName = group.name
                do {
                    let groupTags = try app.context.tags(for: group)
                    tempTags = Set( groupTags.map{ IGTempTag(from: $0, ignoring: group.id) })
                } catch {
                    app.appError = .groupFailure("Failed to fetch group tags: \(error.localizedDescription)")
                }
            }
        }
        .alert("A group with that name already exists.", isPresented: $isShowingDuplicateAlert) {
            Button("OK", role: .cancel) { }
        }
    }
    
    private func saveGroup() {
        do {
            let wasCreatedOrUpdated: Bool
            
            if let group {
                wasCreatedOrUpdated = try IGGroupManager.updateGroup(
                    group,
                    to: tempName,
                    with: tempTags,
                    in: app.context
                )
            } else {
                wasCreatedOrUpdated = try IGGroupManager.newGroup(
                    tempName,
                    with: tempTags,
                    design: settings.workspace.workspace.designKey,
                    in: app.context
                )
            }
            
            guard wasCreatedOrUpdated else {
                isShowingDuplicateAlert = true
                return
            }
            
            try app.context.save()
            if try IGTagManager.cleanOrphanTags(in: app.context) > 0 {
                try app.context.save()
            }
            dismiss()
            
        } catch {
            if group != nil {
                app.appError = .groupFailure("Failed to update group: \(error.localizedDescription)")
            } else {
                app.appError = .groupFailure("Failed to add group: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    @Previewable @State var app: IGAppModel = .init()
    @Previewable @State var settings: IGAppSettings = .init()
    @Previewable @State var group: IGGroup?
    
    IGGroupInfoSheet(group)
        .environment(app)
        .environment(settings)
}
