//
//  IGRecordDetailView.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-11-08.
//

import SwiftUI

struct IGRecordDetail: View {
    
    private let record: IGRecord
    
    init(_ record: IGRecord) {
        self.record = record
    }
    
    private var tags: [IGTempTag] {
        record.tagSnapshots.map { IGTempTag(from: $0) }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                VStack {
                    Text(record.design.displayText(record.phraseValue))
                        .font(.largeTitle)
                        .multilineTextAlignment(.center)
                    Text(record.key.description)
                        .font(.title)
                        .multilineTextAlignment(.center)
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top,24)
            Form() {
                Section("Metadata"){
                    LabeledContent("Title") {
                        Text(record.title)
                    }
                    LabeledContent("Author") {
                        Text(record.author)
                    }
                    LabeledContent("Description") {
                        Text(record.descriptionText)
                    }
                    LabeledContent("Revision") {
                        Text("\(record.revision.spelledOutRevision)")
                    }
                }
                Section("Tags"){
                    IGTagList(tags)
                }
                Section("Image") {
                    LabeledContent("File Name") {
                        Text(record.fileName + ".png")
                    }
                    LabeledContent("Created") {
                        Text(record.dateCreated.displayString)
                    }
                    LabeledContent("Rendered") {
                        Text(record.dateRendered?.displayString ?? record.status.description)
                    }
                    LabeledContent("Uploaded") {
                        Text(record.dateUploaded?.displayString ?? "Not Uploaded")
                    }
                }
            }
            .formStyle(.grouped)
        }
    }
}

#Preview {
    IGRecordDetail(IGRecord(tags: [
        IGTag("Cool Dude", scope: .group),
        IGTag("Cheese", scope: .defaults, isPreset: true),
        IGTag("Cool Dude", scope: .group),
        IGTag("Cool Dude", scope: .group),
        IGTag("Cool Dude", scope: .group),
        IGTag("Cool Dude", scope: .group),
        IGTag("Cool Dude", scope: .group)
    ]))
}
