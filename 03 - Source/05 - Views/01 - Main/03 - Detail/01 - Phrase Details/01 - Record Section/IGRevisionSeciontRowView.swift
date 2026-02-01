//
//  IGRevisionSeciontRowView.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2026-01-31.
//

import SwiftUI

struct IGRevisionSeciontRow: View {
    
    private var revision: Int = 0
    private var status: IGRecordStatus?
    
    init(_ revision: Int, status: IGRecordStatus?) {
        self.status = status
        self.revision = revision
    }
    
    var body: some View {
        VStack {
            Divider()
            LabeledContent("\(revision.spelledOutRevision)") {
                if let status = status {
                    HStack(alignment: .firstTextBaseline) {
                        Image(systemName: status.symbol)
                            .foregroundStyle(.secondary)
                        Text(status.description)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    HStack(alignment: .firstTextBaseline) {
                        Image(systemName: "trash")
                            .foregroundStyle(.red)
                        Text("Deleted")
                            .foregroundStyle(.red)
                    }
                }
            }
            .labelStyle(.titleAndIcon)
        }
        .padding(.leading, 12)
        .padding(.trailing, 4)
    }
}

#Preview {
    IGRevisionSeciontRow(3, status: nil)
}
