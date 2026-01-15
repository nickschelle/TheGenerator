//
//  IGImageQueuesListView.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-10-10.
//

import SwiftUI
import SwiftData

struct IGImageQueuesSection: View {
    
    @Environment(IGAppModel.self) private var app
    
    var body: some View {
        Section("Image Queues") {
            IGRenderQueueSidebarItem().tag(IGContentSelection.renderQueue)
            IGUploadQueueSidebarItem().tag(IGContentSelection.uploadQueue)
        }
    }
}

#Preview {
    
    @Previewable @State var app: IGAppModel = .init()
    
    IGImageQueuesSection()
        .environment(app)
}
