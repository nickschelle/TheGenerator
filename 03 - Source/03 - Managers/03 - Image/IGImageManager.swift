//
//  IHImageManager.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-10-06.
//

import Foundation
import SwiftData
import Cocoa
import CoreGraphics

enum IGImageManager {
    
    static func generateRecordImages(
        _ records: [IGRecord],
        in app: IGAppModel,
        using folderURL: URL
    ) async {
        
        actor RenderProgress {
            private var completed = 0
            let total: Int
            
            init(total: Int) {
                self.total = total
            }
            
            func increment() -> Double {
                completed += 1
                return Double(completed) / Double(total)
            }
            
            var count: Int { completed }
        }
        
        let total = records.count
        guard total > 0 else { return }
        
        let batchStart = Date()
        let progress = RenderProgress(total: total)
        
        await MainActor.run {
            app.generationState = .rendering
            app.generationMessage = "Rendering \(total) images..."
            app.generationProgress = 0.0
        }
        
        guard folderURL.startAccessingSecurityScopedResource() else {
            await MainActor.run {
                app.generationState = .failed
                app.generationMessage = "❌ Could not access security-scoped folder."
                app.generationProgress = nil
            }
            return
        }
        
        defer { folderURL.stopAccessingSecurityScopedResource() }
        
        let maxConcurrentRenders =
        max(2, ProcessInfo.processInfo.activeProcessorCount - 1)
        
        await withTaskGroup(of: Void.self) { group in
            var iterator = records.makeIterator()
            
            // Seed initial tasks
            for _ in 0..<maxConcurrentRenders {
                if let record = iterator.next() {
                    group.addTask {
                        await render(record)
                    }
                }
            }
            
            // Keep pipeline full
            while await group.next() != nil {
                if Task.isCancelled { break }
                
                if let next = iterator.next() {
                    group.addTask {
                        await render(next)
                    }
                }
            }
        }
        
        let duration = Date().timeIntervalSince(batchStart)
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .abbreviated
        
        let durationString =
        formatter.string(from: duration) ?? duration.formatted()
        
        let completed = await progress.count
        
        await MainActor.run {
            app.generationState = .complete
            app.generationMessage =
            "✔️ Rendered \(completed)/\(total) images in \(durationString)"
            app.generationProgress = nil
        }
        
        // MARK: - Per-record render task
        
        func render(_ record: IGRecord) async {
            if Task.isCancelled { return }
            
            // Skip already processed
            if record.dateRendered != nil && record.status != .rendered {
                return
            }
            
            let renderStart = Date()
            
            await MainActor.run {
                app.generationMessage = "Rendering \(record.phraseValue)..."
                record.markAsDrawing()
                try? app.context.save()
            }
            
            let fileURL = folderURL
                .appendingPathComponent(record.fileName)
                .appendingPathExtension("png")
            
            do {
                // 🔥 Heavy work (parallel-safe)
                let cgImage = try record.design.renderImage(
                    of: record.phraseValue,
                    at: record.size,
                    with: record.rawTheme
                )
                
                await MainActor.run {
                    record.markAsSaving()
                    try? app.context.save()
                }
                
                try cgImage.savePNG(to: fileURL, metadata: record.metadata)
                
                let duration = Date().timeIntervalSince(renderStart)
                
                await MainActor.run {
                    record.markAsRendered(duration)
                    try? app.context.save()
                }
                
                let progressValue = await progress.increment()
                
                await MainActor.run {
                    app.generationProgress = progressValue
                }
                
            } catch {
                await MainActor.run {
                    record.markRenderAsFailed(
                        "Render/save failed: \(error.localizedDescription)"
                    )
                    app.generationMessage = "❌ Failed for \(record.phraseValue)"
                    try? app.context.save()
                }
            }
        }
    }
}
    
    /*
    func generateRecordImages(
        _ records: [IGRecord],
        in app: IGAppModel,
        using folderURL: URL
    ) {
        let total = records.count
        guard total > 0 else { return }

        let batchStart = Date()
        app.generationState = .rendering
        app.generationMessage = "Rendering \(total) images..."
        app.generationProgress = 0.0

        renderWorkItem = DispatchWorkItem { [weak self] in
            guard let self else { return }
            var completed = 0

            guard folderURL.startAccessingSecurityScopedResource() else {
                DispatchQueue.main.async {
                    app.generationState = .failed
                    app.generationMessage = "❌ Could not access security-scoped folder."
                    app.generationProgress = nil
                }
                return
            }

            defer { folderURL.stopAccessingSecurityScopedResource() }

            for record in records {

                // Cancellation check
                if self.renderWorkItem?.isCancelled == true {
                    DispatchQueue.main.async {
                        app.generationState = .cancelled
                        app.generationMessage = "❌ Rendering cancelled"
                        app.generationProgress = nil
                    }
                    break
                }

                // Skip already-rendered
                if record.dateRendered != nil && record.status != .rendered {
                    DispatchQueue.main.async {
                        app.generationMessage = "⚠️ Skipping already processed: \(record.phraseValue)"
                    }
                    continue
                }

                // Begin rendering
                let renderStart = Date()
                DispatchQueue.main.async {
                    app.generationMessage = "Rendering \(record.phraseValue)..."
                }

                let fileURL = folderURL
                    .appendingPathComponent(record.fileName)
                    .appendingPathExtension("png")

                DispatchQueue.main.async {
                    record.markAsDrawing()
                    try? app.context.save()
                }

                let cgImage = try record.design.renderImage(
                    of: record.phraseValue, at: record.size, with: record.rawTheme
                    )
                /*
                ) else {
                    DispatchQueue.main.async {
                        record.markRenderAsFailed("Failed to render image")
                        app.generationMessage = "❌ Failed to render \(record.phraseValue)"
                        try? app.context.save()
                    }
                    continue
*/
                DispatchQueue.main.async {
                    record.markAsSaving()
                    try? app.context.save()
                }

                do {
                    try cgImage.savePNG(to: fileURL, metadata: record.metadata)

                    DispatchQueue.main.async {
                        let duration = Date().timeIntervalSince(renderStart)
                        record.markAsRendered(duration)
                        try? app.context.save()
                    }

                    completed += 1
                    DispatchQueue.main.async {
                        app.generationProgress = Double(completed) / Double(total)
                    }

                } catch {
                    DispatchQueue.main.async {
                        record.markRenderAsFailed("Image save failed: \(error.localizedDescription)")
                        app.generationMessage = "❌ Save failed for \(record.phraseValue)"
                        try? app.context.save()
                    }
                }
            }

            // Final completion
            DispatchQueue.main.async {
                switch app.generationState {
                case .cancelled, .failed:
                    app.generationProgress = nil
                    return
                default:
                    break
                }

                let duration = Date().timeIntervalSince(batchStart)
                let formatter = DateComponentsFormatter()
                formatter.allowedUnits = [.minute, .second]
                formatter.unitsStyle = .abbreviated
                let durationString = formatter.string(from: duration) ?? duration.formatted()

                app.generationState = .complete
                app.generationMessage = "✔️ Rendered \(completed)/\(total) images in \(durationString)"
                app.generationProgress = nil
            }
        }

        if let item = renderWorkItem {
            DispatchQueue.global(qos: .userInitiated).async(execute: item)
        }
    }
     */

/*
    func uploadRecordImages(
        _ records: [IGRecord],
        in app: IGAppModel,
        from localRoot: URL,
        config: IGFTPConfig = .load()
    ) {
        let total = records.count
        guard total > 0 else { return }

        // Prepare concurrency controls
        let semaphore = DispatchSemaphore(value: config.maxConcurrentUploads)
        let syncQueue = DispatchQueue(label: "IHImageManager.upload.sync")
        let start = Date()
        var completed = 0

        uploadWorkItem = DispatchWorkItem { [weak self] in
            guard let self else { return }

            // Cancellation before starting
            if self.uploadWorkItem?.isCancelled == true {
                Task { @MainActor in
                    app.uploadState = .cancelled
                    app.uploadMessage = "❌ Upload cancelled"
                    app.uploadProgress = nil
                }
                return
            }

            Task { @MainActor in
                app.uploadState = .uploading
                app.uploadMessage = "Uploading \(total) images..."
                app.uploadProgress = 0.0
            }

            let group = DispatchGroup()

            for record in records {
                semaphore.wait()
                group.enter()

                DispatchQueue.global(qos: .utility).async {

                    guard localRoot.startAccessingSecurityScopedResource() else {
                        Task { @MainActor in
                            app.uploadState = .failed
                            app.uploadMessage = "❌ Could not access security-scoped folder."
                            app.uploadProgress = nil
                        }
                        semaphore.signal()
                        group.leave()
                        return
                    }

                    defer { localRoot.stopAccessingSecurityScopedResource() }

                    self.uploadSingleRecord(
                        record,
                        app: app,
                        localRoot: localRoot,
                        config: config
                    )

                    syncQueue.sync {
                        completed += 1
                        let progress = Double(completed) / Double(total)
                        Task { @MainActor in app.uploadProgress = progress }
                    }

                    semaphore.signal()
                    group.leave()
                }
            }

            // Wrap-up
            group.notify(queue: .main) {
                guard app.uploadState != .cancelled,
                      app.uploadState != .failed else {
                    app.uploadProgress = nil
                    return
                }

                let duration = Date().timeIntervalSince(start)
                let seconds = String(format: "%.1f", duration)

                app.uploadState = .complete
                app.uploadMessage = "✔️ Uploaded \(total) images in \(seconds)s"
                app.uploadProgress = nil
            }
        }

        if let item = uploadWorkItem {
            DispatchQueue.global(qos: .userInitiated).async(execute: item)
        }
    }


    // MARK: - Internal upload helper

    private func uploadSingleRecord(
        _ record: IGRecord,
        app: IGAppModel,
        localRoot: URL,
        config: IGFTPConfig
    ) {
        let fileURL = localRoot
            .appendingPathComponent(record.fileName)
            .appendingPathExtension("png")

        let remotePath = config.remoteBasePath
            .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? config.remoteBasePath

        let remoteFilename = (record.fileName + ".png")
            .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
            ?? (record.fileName + ".png")

        let remoteURL = "ftp://\(config.host):\(config.port)\(remotePath)/\(remoteFilename)"

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/curl")
        process.arguments = [
            "-T", fileURL.path,
            remoteURL,
            "--user", "\(config.username):\(config.password)",
            "--silent", "--show-error", "--fail"
        ]

        let pipe = Pipe()
        process.standardError = pipe

        let uploadStart = Date()

        Task { @MainActor in
            record.markAsUploading()
            try? app.context.save()
            app.uploadMessage = "Uploading \(record.fileName)..."
        }

        do {
            try process.run()
            process.waitUntilExit()
            let duration = Date().timeIntervalSince(uploadStart)

            Task { @MainActor in
                if process.terminationStatus == 0 {
                    record.markAsUploaded(duration)
                } else {
                    let errorData = pipe.fileHandleForReading.readDataToEndOfFile()
                    let message = String(data: errorData, encoding: .utf8) ?? "Unknown error"
                    record.markUploadAsFailed("Upload failed: \(message)")
                    app.uploadMessage = "❌ Failed to upload \(record.fileName)"
                }

                try? app.context.save()
            }

        } catch {
            Task { @MainActor in
                record.markUploadAsFailed("Upload error: \(error.localizedDescription)")
                app.uploadMessage = "❌ Failed to upload \(record.fileName)"
                try? app.context.save()
            }
        }
    }


    // ======================================================================
    // MARK: - Cancellation
    // ======================================================================

    func cancelRendering(in app: IGAppModel) {
        renderWorkItem?.cancel()
        DispatchQueue.main.async {
            app.generationState = .cancelled
            app.generationMessage = "❌ Rendering cancelled"
            app.generationProgress = nil
        }
    }

    func cancelUpload(in app: IGAppModel) {
        uploadWorkItem?.cancel()
        DispatchQueue.main.async {
            app.uploadState = .cancelled
            app.uploadMessage = "❌ Upload cancelled"
            app.uploadProgress = nil
        }
    }
    /*
    @MainActor
    static func loadPNG(
        at fileName: String,
        in folderURL: URL
    ) async throws -> IGLoadedPNG {

        // Open security scope on the main actor
        guard folderURL.startAccessingSecurityScopedResource() else {
            throw NSError(
                domain: "IHImageManager",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Security scope denied"]
            )
        }
        defer { folderURL.stopAccessingSecurityScopedResource() }

        // Perform CPU + IO work in a detached task
        return try await Task.detached(priority: .userInitiated) {

            // ---- Construct file URL inside the worker thread ----
            let fileURL = folderURL
                .appendingPathComponent(fileName)
                .appendingPathExtension("png")

            // ---- Load Image ----
            guard let image = NSImage(contentsOf: fileURL) else {
                throw NSError(
                    domain: "IHImageManager",
                    code: 2,
                    userInfo: [NSLocalizedDescriptionKey: "Failed to decode PNG"]
                )
            }

            // ---- Load Metadata ----
            let metadata = try Self.extractMetadata(from: fileURL)

            return IGLoadedPNG(image: image, metadata: metadata)

        }.value
    }

    // MARK: - Reading IHImageMetadata from PNG
    nonisolated
    private static func extractMetadata(from url: URL) throws -> IGImageMetadata {

        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            throw NSError(
                domain: "IHImageManager",
                code: 3,
                userInfo: [NSLocalizedDescriptionKey: "CGImageSourceCreateWithURL failed"]
            )
        }

        guard let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil)
                as? [String: Any] else {
            throw NSError(
                domain: "IHImageManager",
                code: 4,
                userInfo: [NSLocalizedDescriptionKey: "No PNG properties found"]
            )
        }

        // PNG → kCGImagePropertyPNGDictionary
        let png = properties[kCGImagePropertyPNGDictionary as String] as? [String: Any]

        let title        = png?[kCGImagePropertyPNGTitle as String] as? String ?? ""
        let description  = png?[kCGImagePropertyPNGDescription as String] as? String ?? ""
        let author       = png?[kCGImagePropertyPNGAuthor as String] as? String ?? ""
        let version      = png?[kCGImagePropertyPNGSoftware as String] as? String ?? ""

        // IPTC → keywords
        let iptc = properties[kCGImagePropertyIPTCDictionary as String] as? [String: Any]
        let keywordList = iptc?[kCGImagePropertyIPTCKeywords as String] as? [String] ?? []

        return IGImageMetadata(
            title: title,
            detailDescription: description,
            author: author,
            keywords: keywordList,
            versionInfo: version
        )
    }
     */
}
 */
