//
//  IGEditGroupButton.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-10-22.
//

import SwiftUI

struct IGEditGroupButton: View {
    
    @Environment(IGAppModel.self) private var app
    
    let group: IGGroup?
    
    init(_ group: IGGroup? = nil) {
        self.group = group
    }
    
    var body: some View {
        IGModelActionButton(
            group,
            selected: app.selectedGroup,
            actionTitle: "Edit",
            systemImage: "pencil",
            action: editGroup
        )
    }
    
    private func editGroup(_ group: IGGroup) {
        app.activeSheet = .editGroup(group)
    }
}

#Preview {
    @Previewable @State var app: IGAppModel = .init()
    
    IGEditGroupButton(IGGroup("Shit"))
        .environment(app)
}

