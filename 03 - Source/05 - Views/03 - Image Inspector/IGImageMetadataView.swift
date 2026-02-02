//
//  IHPNGMetadataView.swift
//  IHeartEverything
//
//  Created by Nick Schelle on 2025-11-23.
//

import SwiftUI

struct IGImageMetadataView: View {
    
    @Environment(IGAppModel.self) private var app
    @Environment(IGAppSettings.self) private var settings
    @Environment(\.dismiss) private var dismiss

    let metadata: IGImageMetadata
    
    init(_ metadata: IGImageMetadata)  {
        self.metadata = metadata
    }
    
    var tags: [IGTempTag] {
        metadata.keywords
            .map { IGTempTag($0, scope: .snapshot) }
            .sorted { $0.value < $1.value }
    }

    var body: some View {
        
        Form {
            Section("Image Info") {
                LabeledContent("Title", value: metadata.title)
                LabeledContent("Author", value: metadata.author)
                LabeledContent("Version Info", value: metadata.versionInfo)
            }
            Section("Description") {
                Text(metadata.detailDescription)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.secondary)
                
            }
            Section("Keywords") {
                IGTagList(tags)
            }

        }
        .formStyle(.grouped)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close", role: .close) {
                    dismiss()
                }
            }
        }
    }
}
    
#Preview {
    @Previewable @State var app: IGAppModel = .init()
    @Previewable @State var settings: IGAppSettings = .init()
    @Previewable @State var metadata = IGImageMetadata(title: "This is a Title", detailDescription: "Cool Stuff inside", author: "Stank", keywords: ["house", "PigPen", "Shops"], versionInfo: "33 Achres")
    
    IGImageMetadataView(metadata)
        .environment(app)
        .environment(settings)
}
