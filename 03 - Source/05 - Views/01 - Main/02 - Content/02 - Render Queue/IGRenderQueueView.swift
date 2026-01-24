//
//  IGRenderQueueView.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-11-03.
//

import SwiftUI
import SwiftData

struct IGRenderQueue: View {
   
    var body: some View {
        
        IGQueue(
            "Render Queue",
            predicate: #Predicate<IGRecord> {
                $0.dateRendered == nil
            }
        )
        .toolbar {
            ToolbarItemGroup {
                IGRenderImagesButton()
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
    IGRenderQueue()
}
