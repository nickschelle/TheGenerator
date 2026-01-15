//
//  IGContentView.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-10-22.
//

import SwiftUI

struct IGContentView: View {
    
    @Environment(IGAppModel.self) private var app
    
    var body: some View {
        Group {
            if let selectedItem = app.selectedContent {
                switch selectedItem {
                case .allPhrases: IGPhraseList(for: nil)
                case .group(let group): IGPhraseList(for: group)
                case .renderQueue: IGRenderQueue()
                case .uploadQueue: IGUploadQueue()
                }
            } else if app.selectedContents.count > 1 {
                Text("Multiple groups selected")
                    .foregroundStyle(.secondary)
            } else {
                Text("Select an item from the sidebar")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    @Previewable @State var app: IGAppModel = .init()
    
    IGContentView()
        .environment(app)
}
