//
//  IGRevisionSectionView.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2026-02-01.
//

import SwiftUI

struct IGRevisionSection: View {
    
    private let recordKey: IGRecordKey
    private let revisions: [IGRecord?]
    
    init (_ revisions: [IGRecord?], for recordKey: IGRecordKey) {
        self.revisions = revisions
        self.recordKey = recordKey
    }
    
    private var maxRevision: Int {
        revisions.count - 1
    }
    
    var body: some View {
        DisclosureGroup {
            ForEach(revisions.indices.reversed(), id: \.self) { revision in
                let record = revisions[revision]
                if !hideRevision(revision: revision, record: record) {
                    IGRevisionSeciontRow(revision, status: record?.status)
                }
                
            }
        } label: {
            IGDesignSectionRow(
                recordKey.displayValue(includeDesign: false),
                revision: 1,
                isNew: maxRevision == 0
            )
        }
    }
    
    private func hideRevision(
        revision: Int,
        record: IGRecord?
    ) -> Bool {
        revision == maxRevision && record == nil
    }
}

#Preview {
    IGRevisionSection([], for: IGRecordKey(from: IGRecord()))
}
