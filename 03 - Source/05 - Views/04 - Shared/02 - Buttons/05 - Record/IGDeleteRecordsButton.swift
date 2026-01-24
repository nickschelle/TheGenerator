//
//  IGDeleteRecordsButton.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-10-21.
//

import SwiftUI
import SwiftData

struct IGDeleteRecordsButton: View {
    
    @Environment(IGAppModel.self) private var app
    @Environment(IGAppSettings.self) private var settings
    
    private let record: IGRecord?
    
    init(_ record: IGRecord? = nil) {
        self.record = record
    }
    
    var deleteConfirmation: IGConfirmationContent {
        IGConfirmationContent(
            confirmTitle: "Delete", confirmRole: .destructive, message: {
                Text("Any linked rendered images will be deleted as well.")
            }
        )
    }
    
    var body: some View {
        IGModelActionButton(
            record,
            selection: app.selectedRecords,
            actionTitle: "Delete",
            systemImage: "trash",
            confirmation: deleteConfirmation,
            action: delete)
    }
    
    private func delete(_ records: any Collection<IGRecord>) {
        do {
            try IGRecordManager.deleteRecords(records, with: settings, in: app.context)
            try app.context.save()
        } catch {
            app.appError = .recordFailure("Failed to delete record: \(error.localizedDescription)")
        }
    }
}

#Preview {
    
    @Previewable @State var app: IGAppModel = .init()
    
    IGDeletePhrasesButton()
        .environment(app)
}
