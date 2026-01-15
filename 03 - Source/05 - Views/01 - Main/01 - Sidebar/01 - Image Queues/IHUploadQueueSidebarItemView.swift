//
//  IHUploadQueueSidebarItemView.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-10-21.
//

import SwiftUI
import SwiftData

struct IGUploadQueueSidebarItem: View {
    
    @Environment(IGAppModel.self) private var app
    @Query private var records: [IGRecord]
    
    init() {
        let rawStatus = IGRecordStatus.replacedInFolder.rawValue
        _records = Query(
            filter: #Predicate<IGRecord> {
                $0.dateRendered != nil &&
                $0.dateUploaded == nil &&
                $0.rawStatus != rawStatus
            },
            sort: [SortDescriptor(\.dateCreated)]
        )
    }
    
    var body: some View {
        IGSidebarItem(
            "Upload Queue",
            systemImage: "square.and.arrow.up.on.square",
            count: records.count,
            //progress: app.uploadProgress
        )
    }
}

#Preview {
    
    @Previewable @State var app: IGAppModel = .init()
    
    IGUploadQueueSidebarItem()
        .environment(app)
}
