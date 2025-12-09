//
//  IGNewGroupButton.swift
//  IHeartEverything
//
//  Created by Nick Schelle on 2025-10-21.
//

import SwiftUI

struct IGNewGroupButton: View {
    @Environment(IGAppModel.self) private var app
    
    var body: some View {
        Button("New Group", systemImage: "rectangle.stack.badge.plus", action: newGroup)
    }
    
    func newGroup() {
        app.activeSheet = .newGroup
    }
}

#Preview {
    @Previewable @State var app: IGAppModel = .init()
    
    IGNewGroupButton()
        .environment(app)
}
