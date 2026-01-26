//
//  IGRenderQueueSidebarItemView.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-10-21.
//

import SwiftUI
import SwiftData

struct IGRenderQueueSidebarItem: View {
    
    @Environment(IGAppModel.self) private var app
    @Query(
        filter: #Predicate<IGRecord> { $0.dateRendered == nil },
        sort: [SortDescriptor(\.dateCreated)]
    ) private var records: [IGRecord]
    
    var body: some View {
        IGSidebarItem(
            "Render Queue",
            systemImage: "photo.stack",
            count: records.count,
            progress: app.generationProgress
        )
    }
}

#Preview {
    
    @Previewable @State var app: IGAppModel = .init()
    
    IGRenderQueueSidebarItem()
        .environment(app)
}
