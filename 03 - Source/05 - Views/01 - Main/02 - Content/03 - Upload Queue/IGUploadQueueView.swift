//
//  IGUploadQueueView.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-11-03.
//

import SwiftUI
import SwiftData

struct IGUploadQueue: View {
    
    @Environment(IGAppModel.self) private var app
    
    private let replacedRaw = IGRecordStatus.replacedInFolder.rawValue
    
    var body: some View {
        VStack {
            Text(app.uploadMessage ?? "Loading...")
            IGQueue(
                "Upload Queue",
                predicate: #Predicate<IGRecord> {
                    $0.dateRendered != nil &&
                    $0.dateUploaded == nil &&
                    $0.rawStatus != replacedRaw
                }
            )
        }
        .toolbar {
            ToolbarItemGroup {
                IGUploadImagesButton()
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
    IGUploadQueue()
}
