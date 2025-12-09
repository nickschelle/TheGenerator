//
//  IGSidebarView.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-10-11.
//

import SwiftUI

struct IGSidebar: View {
    
    @Environment(IGAppModel.self) private var app
    
    var body: some View {
        @Bindable var app = app
        List(selection: $app.selectedContents) {
            //IHImageQueuesSection()
                
            IGPhraseGroupsSection()
        }
        /*
        .onChange(of: app.selectedContents) { old, new in
            app.selectedDetails = []
            if new.count > 1 {
                let groups = new.filter { $0.isGroup }
                if groups.isEmpty {
                    if let last = new.subtracting(old).first ?? new.first {
                        app.selectedContents = [last]
                    }
                } else {
                    app.selectedContents = groups
                }
            }
        }
         */
        .listStyle(.sidebar)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                IGNewGroupButton()
            }
        }
    }
}

#Preview {
    @Previewable @State var app: IGAppModel = .init()
    
    IGSidebar()
        .environment(app)
}
