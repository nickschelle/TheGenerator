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
    
    private let processType: IGImageProcess
    private let predicate: Predicate<IGRecord>
    
    init(_ processType: IGImageProcess, predicate: Predicate<IGRecord>) {
        self.processType = processType
        self.predicate = predicate
    }
    
    private var title: String {
        "\(processType.displayText) Queue"
    }
    
    var body: some View {
        @Bindable var app = app
        VStack(alignment: .leading, spacing: 0) {
            IGContentList(
                title,
                descriptor: FetchDescriptor(
                    predicate: predicate,
                    sortBy: [SortDescriptor(\.dateCreated)]),
                selection: $app.selectedDetails,
                forEachContent: { record in
                    NavigationLink(value: IGDetailSelection.record(record)) {
                        IGContentRow(record.title, systemImage: "photo") {
                            IGRecordStatusView(record)
                        }
                        .contextMenu {
                            IGDeleteRecordsButton(record)
                        }
                    }
                }
            )
            IGQueueStatus(processType)
        }
        .toolbar {
            ToolbarItemGroup {
                switch processType {
                case .render:
                    IGRenderImagesButton()
                case .upload:
                    IGUploadImagesButton()
                }
                Menu("More", systemImage: "ellipsis") {
                    IGDeleteRecordsButton()
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
    IGQueue(.render, predicate: #Predicate<IGRecord> {
        $0.dateRendered == nil
    })
        .frame(width: 400, height: 400)
        .environment(app)
    
}
