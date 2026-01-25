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
    
    @State private var uploadTast: Task<Void, Never>?

    private var recordsAreSelected: Bool {
        !app.selectedRecords.isEmpty
    }

    private var uploadQueue: [IGRecord] {
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
            .disabled((recordsAreSelected ? uploadQueue.isEmpty : false) || app.generationState.isBusy)
    }

    private func onAction() {
        // Cancel active render
        if app.uploadState.isBusy {
            uploadTast?.cancel()
            uploadTast = nil
            return
        }

        // Start render
        uploadTast = Task {

            // Resolve records to render
            let recordsToUpload: [IGRecord]

            if recordsAreSelected {
                recordsToUpload = uploadQueue
            } else {
                do {
                    let replacedRaw = IGRecordStatus.replacedInFolder.rawValue
                    let descriptor = FetchDescriptor<IGRecord>(
                        predicate: #Predicate<IGRecord> {
                            $0.dateRendered != nil &&
                            $0.dateUploaded == nil &&
                            $0.rawStatus != replacedRaw
                        }
                    )
                    recordsToUpload = try app.context.fetch(descriptor)
                } catch {
                    app.appError = .recordFailure("Failed to fetch upload queue.")
                    return
                }
            }
            
            app.ensureLocationAvailableOrImport(
                using: settings.location
            ) { folderURL in
                app.ensureFTPLoginAvailableOrPrompt(
                    using: settings.ftp
                ) { ftp in
                    uploadTast = Task {
                        await IGImageManager.uploadRecordImages(
                            recordsToUpload,
                            in: app,
                            with: settings,
                            from: folderURL
                        )
                    }
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
         
}

#Preview {
    IGUploadImagesButton()
}
