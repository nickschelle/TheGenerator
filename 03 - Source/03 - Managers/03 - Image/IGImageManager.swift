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

        let total = records.count
        guard total > 0 else { return }

        guard folderURL.startAccessingSecurityScopedResource() else {
            await MainActor.run {
                app.generationState = .failed
                app.appError = .renderFailure(
                    "The selected output folder could not be accessed. Please reselect it and try again."
                )
                app.generationProgress = nil
            }
            return
        }

        defer {
            folderURL.stopAccessingSecurityScopedResource()
        }

        let batchStart = Date()
        let progress = ProgressTracker(total: total)

        await MainActor.run {
            app.generationState = .rendering
            app.generationMessage = "Rendering \(total) images…"
            app.generationProgress = 0.0
        }

        let maxConcurrentRenders =
            max(2, ProcessInfo.processInfo.activeProcessorCount - 1)

        await withTaskGroup(of: Void.self) { group in
            var iterator = records.makeIterator()

            for _ in 0..<maxConcurrentRenders {
                if let record = iterator.next() {
                    group.addTask {
                        await render(
                            record,
                            app: app,
                            folderURL: folderURL,
                            progress: progress
                        )
                    }
                }
            }

            while await group.next() != nil {
                if Task.isCancelled { break }
                if let next = iterator.next() {
                    group.addTask {
                        await render(
                            next,
                            app: app,
                            folderURL: folderURL,
                            progress: progress
                        )
                    }
                }
            }
        }

        let duration = Date().timeIntervalSince(batchStart)
        let completed = await progress.count

        await MainActor.run {
            guard app.generationState != .failed,
                  app.generationState != .cancelled else {
                app.generationProgress = nil
                return
            }

            app.generationState = .complete
            app.generationMessage =
                "✔️ Rendered \(completed)/\(total) images in \(duration.formatted())"
            app.generationProgress = nil
        }
    }
    
    static private func render(_ record: IGRecord, app: IGAppModel, folderURL: URL, progress: ProgressTracker) async {
        guard !Task.isCancelled else { return }
        guard !record.isRendered else { return }

        let renderStart = Date()

        await MainActor.run {
            record.markAsDrawing()
            do {
                try app.context.save()
            } catch {
                record.markRenderAsFailed(
                    "Failed to save render state: \(error.localizedDescription)"
                )
                app.generationState = .failed
                app.appError = .recordFailure(
                    "An internal error occurred while preparing images for rendering."
                )
            }
        }

        let fileURL = folderURL
            .appendingPathComponent(record.fileName)
            .appendingPathExtension("png")

        do {
            let cgImage = try record.design.renderImage(
                of: record.phraseValue,
                at: record.size,
                with: record.rawTheme
            )

            try await MainActor.run {
                record.markAsSaving()
                try app.context.save()
            }

            try cgImage.savePNG(to: fileURL, metadata: record.metadata)

            let duration = Date().timeIntervalSince(renderStart)

            try await MainActor.run {
                record.markAsRendered(duration)
                try app.context.save()
            }

            let value = await progress.increment()

            await MainActor.run {
                app.generationProgress = value
            }

        } catch {
            await MainActor.run {
                record.markRenderAsFailed(
                    "Render failed: \(error.localizedDescription)"
                )

                do {
                    try app.context.save()
                } catch {
                    app.generationState = .failed
                    app.appError = .recordFailure(
                        "An internal error occurred while saving render results."
                    )
                }
            }
        }
    }
    
    static func uploadRecordImages(
        _ records: [IGRecord],
        in app: IGAppModel,
        with settings: IGAppSettings,
        from localRoot: URL
    ) async {
        
        guard localRoot.startAccessingSecurityScopedResource() else {
            app.appError = .uploadFailure(
                "The selected output folder could not be accessed. Please reselect it and try again."
            )
            return
        }

        defer {
            localRoot.stopAccessingSecurityScopedResource()
        }

        guard !records.isEmpty else {
            app.appError = .uploadFailure(
                "There are no images selected to upload."
            )
            return
        }

        let payloads = makeUploadPayloads(
            from: records,
            in: app,
            localRoot: localRoot,
            config: settings.ftp
        )

        guard !payloads.isEmpty else {
            app.uploadState = .failed
            app.uploadProgress = nil

            app.appError = .uploadFailure(
                "None of the selected images could be prepared for upload."
            )

            return
        }

        app.uploadState = .uploading
        app.uploadMessage = "Uploading \(payloads.count) images…"
        app.uploadProgress = 0.0

        await uploadPayloads(payloads, in: app, with: settings)
    }


    private struct UploadPayload: Sendable {
        let recordID: UUID
        let fileURL: URL
        let remoteURL: String
        let fileName: String
    }

    private actor ProgressTracker {
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
        

    @MainActor
    private static func makeUploadPayloads(
        from records: [IGRecord],
        in app: IGAppModel,
        localRoot: URL,
        config: IGFTPConfig
    ) -> [UploadPayload] {

        app.uploadBatch = Dictionary(
            uniqueKeysWithValues: records.map { ($0.id, $0) }
        )

        var payloads: [UploadPayload] = []

        for record in records {

            let fileURL = localRoot
                .appendingPathComponent(record.fileName)
                .appendingPathExtension("png")

            guard FileManager.default.fileExists(atPath: fileURL.path) else {
                record.markUploadAsFailed("Rendered image file not found on disk.")
                continue
            }

            guard let encodedPath =
                config.remoteBasePath.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
            else {
                record.markUploadAsFailed("Invalid remote base path.")
                continue
            }

            let rawFilename = record.fileName + ".png"

            guard let encodedFilename =
                rawFilename.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
            else {
                record.markUploadAsFailed("Invalid filename for upload.")
                continue
            }

            let remoteURL =
                "ftp://\(config.host):\(config.port)\(encodedPath)/\(encodedFilename)"

            record.markAsUploading()

            payloads.append(
                UploadPayload(
                    recordID: record.id,
                    fileURL: fileURL,
                    remoteURL: remoteURL,
                    fileName: record.fileName
                )
            )
        }

        return payloads
    }
    
    private static func uploadPayloads(
        _ payloads: [UploadPayload],
        in app: IGAppModel,
        with settings: IGAppSettings
    ) async {

        defer {
            Task { @MainActor in
                app.uploadBatch = nil
            }
        }

        let total = payloads.count
        let progress = ProgressTracker(total: total)
        let start = Date()

        await withTaskGroup(of: Void.self) { group in
            for payload in payloads {
                group.addTask(priority: .utility) {
                    await uploadOne(payload, app: app, settings: settings, progress: progress)
                }
            }
        }

        let duration = Date().timeIntervalSince(start)

        await MainActor.run {

            guard app.uploadState != .failed,
                  app.uploadState != .cancelled else {
                app.uploadProgress = nil
                return
            }

            let uploaded = app.uploadBatch?
                .values
                .filter { $0.isUploaded }
                .count ?? 0

            guard uploaded > 0 else {
                app.uploadState = .failed
                app.uploadProgress = nil
                app.appError = .uploadFailure(
                    "None of the images could be uploaded. Please check your FTP settings and try again."
                )
                return
            }

            app.uploadState = .complete
            app.uploadMessage =
                "✔️ Uploaded \(uploaded)/\(total) images in \(String(format: "%.1f", duration))s"
            app.uploadProgress = nil
        }
    }

    private static func uploadOne(
        _ payload: UploadPayload,
        app: IGAppModel,
        settings: IGAppSettings,
        progress: ProgressTracker
    ) async {

        guard !Task.isCancelled else {
            let _ = await progress.increment()
            return
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/curl")
        process.arguments = [
            "-T", payload.fileURL.path,
            payload.remoteURL,
            "--user", "\(settings.ftp.username):\(settings.ftp.password)",
            "--silent",
            "--fail",
            "--ftp-create-dirs"
        ]

        let pipe = Pipe()
        process.standardError = pipe

        let start = Date()

        do {
            try process.run()
            process.waitUntilExit()

            let duration = Date().timeIntervalSince(start)

            let errorData = pipe.fileHandleForReading.readDataToEndOfFile()
            let stderr = String(data: errorData, encoding: .utf8)?
                .trimmingCharacters(in: .whitespacesAndNewlines)

            await MainActor.run {
                guard let record = app.uploadBatch?[payload.recordID] else { return }

                if process.terminationStatus == 0 {
                    record.markAsUploaded(duration)
                } else {
                    record.markUploadAsFailed(
                        stderr?.isEmpty == false ? stderr! : "Upload failed."
                    )
                }

                try? app.context.save()
            }

        } catch {
            await MainActor.run {
                guard let record = app.uploadBatch?[payload.recordID] else { return }
                record.markUploadAsFailed(error.localizedDescription)
                try? app.context.save()
            }
        }

        let value = await progress.increment()

        let step = 1.0 / Double(progress.total)
        let previous = max(0.0, value - step)

        if value == 1.0 || Int(value * 50) != Int(previous * 50) {
            await MainActor.run {
                app.uploadProgress = value
            }
        }
    }
}
    
    

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
