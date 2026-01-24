//
//  IGUploadImagesButton.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-11-02.
//

import SwiftUI
import SwiftData

struct IGUploadImagesButton: View {
    @Environment(IGAppModel.self) private var app
    @Environment(IGAppSettings.self) private var settings

    private var recordsAreSelected: Bool {
        !app.selectedRecords.isEmpty
    }

    private var selectedRecordsSorted: [IGRecord] {
        Array(app.selectedRecords.sorted { $0.dateCreated < $1.dateCreated })
    }

    private var title: String {
        recordsAreSelected ? "Upload Selected Images" : "Upload Images"
    }

    private var symbol: String {
        app.uploadState.isBusy ? "stop.fill" : "arrow.up.circle.fill"
    }

    var body: some View {
        Button(title, systemImage: symbol, action: onAction)
            .disabled((recordsAreSelected ? selectedRecordsSorted.isEmpty : false) || app.generationState.isBusy)
    }

    private func onAction() {
        /*
        if app.uploadState.isBusy {
            app.imageManager.cancelUpload(in: app)
        } else {
            Task {
                let recordsToUpload: [IGRecord]

                if recordsAreSelected {
                    recordsToUpload = selectedRecordsSorted
                } else {
                    do {
                        recordsToUpload = try app.context.fetch(IGImageRecordFilter.upload.fetchDescriptor)
                    } catch {
                        print("❌ Failed to fetch upload queue:", error)
                        return
                    }
                }

                app.ensureLocationAvailableOrImport(
                    using: settings.location
                ) { folderURL in
                    app.ensureFTPLoginAvailableOrPrompt(
                        using: settings.ftp
                    ) { ftp in
                        app.imageManager.uploadRecordImages(recordsToUpload, in: app, from: folderURL, config: settings.ftp)
                    } onFailure: {
                        app.uploadState = .failed
                        app.uploadMessage = "No output folder selected."
                    }
                } onFailure: {
                    app.uploadState = .failed
                    app.uploadMessage = "No output folder selected."
                }

            }
        }
         */
    }
         
}

#Preview {
    IGUploadImagesButton()
}
