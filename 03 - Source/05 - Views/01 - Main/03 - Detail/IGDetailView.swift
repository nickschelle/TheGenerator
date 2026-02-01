//
//  IGDetailView.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-10-22.
//

import SwiftUI

struct IGDetailView: View {
    @Environment(IGAppModel.self) private var app

    var selectionMessage: String {

        switch app.selectedContent {
        case .allPhrases: app.selectedPhrases.isEmpty ?
            "Select a phrase in All Phrases" :
            "Multiple phrases selected"

        case .group(let group): app.selectedPhrases.isEmpty ?
            "Select a phrase in '\(group.name)'" :
            "Multiple phrases selected"

        case .renderQueue: app.selectedRecords.isEmpty ?
            "Select a record in the Render Queue" :
            "Multiple records selected"

        case .uploadQueue: app.selectedRecords.isEmpty ?
            "Select a record in the Upload Queue" :
            "Multiple records selected"

        case .none: "Select an item from the sidebar"
        }
    }
    
    var body: some View {
        @Bindable var app = app

        NavigationStack(path: $app.detailPath) {
            Group {
                if let detailItem = app.selectedDetail {
                    switch detailItem {
                    case .phrase(let phrase):
                        IGPhraseDetails(phrase)
                    case .record(let record):
                        IGRecordDetail(record)
                    }
                } else {
                    Text(selectionMessage)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationDestination(for: IGPhrase.self) { IGPhraseDetails($0) }
            .navigationDestination(for: IGRecord.self) { IGRecordDetail($0) }
            .toolbar {
                ToolbarItemGroup {
                    
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var app: IGAppModel = .init()
    
    IGDetailView()
        .environment(app)
}
