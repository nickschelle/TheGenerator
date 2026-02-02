//
//  IGRevisionSectionView.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2026-02-01.
//

import SwiftUI

struct IGRevisionSection: View {
    
    @Environment(IGAppSettings.self) private var settings
    @Environment(\.openWindow) private var openWindow
    
    private let recordKey: IGRecordKey
    private let revisions: [IGRecord?]
    
    init (_ revisions: [IGRecord?], for recordKey: IGRecordKey) {
        self.revisions = revisions
        self.recordKey = recordKey
    }
    
    private var maxRevision: Int {
        revisions.count - 1
    }
    
    private var currentRevision: Int {
        revisions[maxRevision] != nil ? maxRevision : maxRevision - 1
    }
    
    private var imageState: IGDesignSectionRow.ImageState {
        if let latest = revisions[currentRevision] {
            if (try? IGRecordManager.fileExistsfor(latest, at: settings.location)) ?? false {
                return .available
            }
        }
        return .missing
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
                revision: currentRevision,
                imageState: imageState,
                onAction: openImage
            )
        }
    }
    
    private func hideRevision(
        revision: Int,
        record: IGRecord?
    ) -> Bool {
        revision == maxRevision && record == nil
    }
    
    private func openImage() {
        guard let record = revisions[currentRevision] else { return }
        openWindow(value: record.fileName)
    }
}

#Preview {
    IGRevisionSection([], for: IGRecordKey(from: IGRecord()))
}
