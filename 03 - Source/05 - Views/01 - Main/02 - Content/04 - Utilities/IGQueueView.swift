//
//  IGQueueView.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-11-03.
//

import SwiftUI
import SwiftData

struct IGQueue: View {
    @Environment(IGAppModel.self) private var app
    
    private let title: String
    private let predicate: Predicate<IGRecord>
    
    init(_ title: String, predicate: Predicate<IGRecord>) {
        self.title = title
        self.predicate = predicate
    }
    
    var body: some View {
        @Bindable var app = app
        IGContentList(
            title,
            descriptor: FetchDescriptor(
                predicate: predicate,
                sortBy: [SortDescriptor(\.dateCreated)]),
            selection: $app.selectedDetails,
            forEachContent: { record in
                NavigationLink(value: IGDetailSelection.record(record)) {
                    IGContentRow(record.title, systemImage: "photo") {
                        //IGRecordStatusView(record)
                    }
                    .contextMenu {
                        //IGDeleteRecordsButton(record)
                    }
                }
            }
        )
        .toolbar {
            ToolbarItemGroup {
                //IHRenderImagesButton()
                Menu("More", systemImage: "ellipsis") {
                    //IHDeleteRecordsButton()
                    Divider()
                    //IHSelectAllRecords(.render)
                }
                .menuIndicator(.hidden)
            }
        }
    }
}

#Preview {
    @Previewable @State var app: IGAppModel = .init()
    IGQueue("Render Queue", predicate: #Predicate<IGRecord> {
        $0.dateRendered == nil
    })
        .frame(width: 400, height: 400)
        .environment(app)
    
}
