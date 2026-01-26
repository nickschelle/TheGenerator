//
//  IGRenderImagesButton.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-10-28.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct IGRenderImagesButton: View {

    @Environment(IGAppModel.self) private var app
    @Environment(IGAppSettings.self) private var settings

    @State private var renderTask: Task<Void, Never>?

    // MARK: - Derived State

    private var recordsAreSelected: Bool {
        !app.selectedRecords.isEmpty
    }

    private var recordQueue: [IGRecord] {
        Array(app.selectedRecords.sorted { $0.dateCreated < $1.dateCreated })
    }

    private var title: String {
        recordsAreSelected ? "Render Selected Images" : "Render Images"
    }

    private var symbol: String {
        app.generationState.isBusy ? "stop.fill" : "play.fill"
    }

    // MARK: - View

    var body: some View {
        Button(title, systemImage: symbol, action: onAction)
            .disabled(
                (recordsAreSelected && recordQueue.isEmpty) ||
                app.uploadState.isBusy
            )
    }

    // MARK: - Actions

    private func onAction() {

        // Cancel active render
        if app.generationState.isBusy {
            renderTask?.cancel()
            renderTask = nil
            return
        }
        
        if !app.uploadState.isBusy {
            app.resetUploadState()
        }

        // Start render
        renderTask = Task {

            // Resolve records to render
            let recordsToRender: [IGRecord]

            if recordsAreSelected {
                recordsToRender = recordQueue
            } else {
                do {
                    let descriptor = FetchDescriptor<IGRecord>(
                        predicate: #Predicate { $0.dateRendered == nil }
                    )
                    recordsToRender = try app.context.fetch(descriptor)
                } catch {
                    app.appError = .recordFailure("Failed to fetch render queue.")
                    return
                }
            }

            // Ensure output location (sync callback boundary)
            app.ensureLocationAvailableOrImport(
                using: settings.location,
                onSuccess: { folderURL in

                    // Re-enter async world explicitly
                    renderTask = Task {
                        await IGImageManager.generateRecordImages(
                            recordsToRender,
                            in: app,
                            using: folderURL
                        )
                    }
                },
                onFailure: {
                    app.generationState = .cancelled
                    app.generationMessage = "No output folder selected."
                }
            )
        }
    }
}

#Preview {
    IGRenderImagesButton()
}
