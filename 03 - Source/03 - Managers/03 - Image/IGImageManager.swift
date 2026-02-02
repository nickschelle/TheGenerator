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
    
    static func generateRecordImages(
        _ records: [IGRecord],
        in app: IGAppModel,
        with settings: IGAppSettings,
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
            app.generationState = .working
            app.generationMessage = "Rendering \(total) images…"
            app.generationProgress = 0.0
        }

        let maxConcurrentRenders =
        settings.render.concurrency.resolve(
                processorCount: ProcessInfo.processInfo.activeProcessorCount,
                customValue: settings.render.customConcurrency
            )

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
    
    static private func render(
        _ record: IGRecord,
        app: IGAppModel,
        folderURL: URL,
        progress: ProgressTracker
    ) async {
        guard !Task.isCancelled else { return }
        guard !record.isRendered else { return }

        let renderStart = Date()

        await MainActor.run {
            record.markAsDrawing()
            do {
                try app.context.save()
            } catch {
                app.appError = .recordFailure(
                    "An internal error occurred while saving render status."
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

            await MainActor.run {
                record.markAsRendered(duration)
                do {
                    try app.context.save()
                } catch {
                    app.appError = .recordFailure(
                        "An internal error occurred while saving render status."
                    )
                }
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
                    app.appError = .recordFailure(
                        "An internal error occurred while saving render status."
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

        let total = records.count
        guard total > 0 else { return }

        guard localRoot.startAccessingSecurityScopedResource() else {
            await MainActor.run {
                app.uploadState = .failed
                app.appError = .uploadFailure(
                    "The selected output folder could not be accessed. Please reselect it and try again."
                )
                app.uploadProgress = nil
            }
            return
        }

        defer { localRoot.stopAccessingSecurityScopedResource() }

        let progress = ProgressTracker(total: total)

        await MainActor.run {
            app.uploadState = .working
            app.uploadMessage = "Uploading \(total) images…"
            app.uploadProgress = 0
            app.uploadBatch = Dictionary(
                uniqueKeysWithValues: records.map { ($0.id, $0) }
            )
        }

        let maxConcurrentUploads =
            min(settings.ftp.maxConcurrentUploads, records.count)

        await withTaskGroup(of: Void.self) { group in
            var iterator = records.makeIterator()

            for _ in 0..<maxConcurrentUploads {
                if let record = iterator.next() {
                    group.addTask {
                        await upload(
                            record,
                            app: app,
                            settings: settings,
                            localRoot: localRoot,
                            progress: progress
                        )
                    }
                }
            }

            while await group.next() != nil {
                if Task.isCancelled { break }
                if let next = iterator.next() {
                    group.addTask {
                        await upload(
                            next,
                            app: app,
                            settings: settings,
                            localRoot: localRoot,
                            progress: progress
                        )
                    }
                }
            }
        }

        let completed = await progress.count

        await MainActor.run {
            guard app.uploadState != .failed else {
                app.uploadProgress = nil
                return
            }

            app.uploadState = .complete
            app.uploadMessage = "✔️ Uploaded \(completed)/\(total) images"
            app.uploadProgress = nil
        }
    }
    
    private static func upload(
        _ record: IGRecord,
        app: IGAppModel,
        settings: IGAppSettings,
        localRoot: URL,
        progress: ProgressTracker
    ) async {

        guard !Task.isCancelled else { return }
        guard record.isRendered else { return }

        let fileURL = localRoot
            .appendingPathComponent(record.fileName)
            .appendingPathExtension("png")
        
        await MainActor.run {
            record.markUploadAsFailed("Rendered image file not found on disk.")
            do {
                try app.context.save()
            } catch {
                app.appError = .recordFailure(
                    "An internal error occurred while saving upload status."
                )
            }
        }

        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            
            return
        }

        let remoteURL: String
        do {
            remoteURL = try buildRemoteURL(
                for: record,
                config: settings.ftp
            )
        } catch {
            await MainActor.run {
                record.markUploadAsFailed(error.localizedDescription)
                do {
                    try app.context.save()
                } catch {
                    app.appError = .recordFailure(
                        "An internal error occurred while saving upload status."
                    )
                }
            }
            return
        }

        await MainActor.run {
            record.markAsUploading()
            do {
                try app.context.save()
            } catch {
                app.appError = .recordFailure(
                    "An internal error occurred while saving upload status."
                )
            }
        }

        do {
            try await uploadFile(
                fileURL: fileURL,
                remoteURL: remoteURL,
                username: settings.ftp.username,
                password: settings.ftp.password
            )

            let value = await progress.increment()

            await MainActor.run {
                record.markAsUploaded(value)
                do {
                    try app.context.save()
                } catch {
                    app.appError = .recordFailure(
                        "An internal error occurred while saving upload status."
                    )
                }
                app.uploadProgress = value
            }

        } catch {
            await MainActor.run {
                record.markUploadAsFailed(error.localizedDescription)
                do {
                    try app.context.save()
                } catch {
                    app.appError = .recordFailure(
                        "An internal error occurred while saving upload status."
                    )
                }
            }
        }
    }
    
    private static func buildRemoteURL(
        for record: IGRecord,
        config: IGFTPConfig
    ) throws -> String {

        guard
            let encodedPath = config.remoteBasePath
                .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
            let encodedFilename = (record.fileName + ".png")
                .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
        else {
            throw ProcessError.nonZeroExit(0, "Invalid upload path or filename.")
        }

        return "ftp://\(config.host):\(config.port)\(encodedPath)/\(encodedFilename)"
    }
    
    private static func uploadFile(
        fileURL: URL,
        remoteURL: String,
        username: String,
        password: String
    ) async throws {

        try await runProcessAsync(
            executableURL: URL(fileURLWithPath: "/usr/bin/curl"),
            arguments: [
                "-T", fileURL.path,
                remoteURL,
                "--user", "\(username):\(password)",
                "--silent", "--show-error", "--fail"
            ]
        )
    }
    
    enum ProcessError: LocalizedError {
        case nonZeroExit(Int32, String?)

        var errorDescription: String? {
            switch self {
            case let .nonZeroExit(code, stderr):
                if let stderr, !stderr.isEmpty {
                    return stderr
                } else {
                    return "Upload failed with exit code \(code)."
                }
            }
        }
    }
    
    private static func runProcessAsync(
        executableURL: URL,
        arguments: [String]
    ) async throws {

        let process = Process()
        process.executableURL = executableURL
        process.arguments = arguments

        let stderrPipe = Pipe()
        process.standardError = stderrPipe

        try process.run()

        try await withCheckedThrowingContinuation { continuation in
            process.terminationHandler = { process in
                // Read stderr *after* termination (safe, non-blocking here)
                let data = stderrPipe.fileHandleForReading.readDataToEndOfFile()
                let stderr = String(data: data, encoding: .utf8)?
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                if process.terminationStatus == 0 {
                    continuation.resume()
                } else {
                    continuation.resume(
                        throwing: ProcessError.nonZeroExit(
                            process.terminationStatus,
                            stderr
                        )
                    )
                }
            }
        }
    }
    
    @MainActor
    static func loadPNG(
        named fileName: String,
        in folderURL: URL
    ) async throws -> IGLoadedPNG {

        guard folderURL.startAccessingSecurityScopedResource() else {
            throw IGPNGLoadError.securityScopeDenied
        }
        defer { folderURL.stopAccessingSecurityScopedResource() }

        let fileURL = folderURL
            .appendingPathComponent(fileName)
            .appendingPathExtension("png")

        guard let image = NSImage(contentsOf: fileURL) else {
            throw IGPNGLoadError.imageDecodeFailed
        }

        let metadata = try extractMetadata(from: fileURL)

        return IGLoadedPNG(image: image, metadata: metadata)
    }

    nonisolated
    private static func extractMetadata(
        from url: URL
    ) throws -> IGImageMetadata {

        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            throw IGPNGLoadError.imageSourceFailed
        }

        guard
            let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil)
                as? [CFString: Any]
        else {
            throw IGPNGLoadError.propertiesMissing
        }

        let png = properties[kCGImagePropertyPNGDictionary] as? [CFString: Any]
        let iptc = properties[kCGImagePropertyIPTCDictionary] as? [CFString: Any]

        return IGImageMetadata(
            title: png?[kCGImagePropertyPNGTitle] as? String ?? "",
            detailDescription: png?[kCGImagePropertyPNGDescription] as? String ?? "",
            author: png?[kCGImagePropertyPNGAuthor] as? String ?? "",
            keywords: iptc?[kCGImagePropertyIPTCKeywords] as? [String] ?? [],
            versionInfo: png?[kCGImagePropertyPNGSoftware] as? String ?? ""
        )
    }
    
}

enum IGPNGLoadError: Error {
    case securityScopeDenied
    case imageDecodeFailed
    case imageSourceFailed
    case propertiesMissing
}


/*
 
 
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

     app.uploadState = .working
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
     
     let maxConcurrentUploads = min(
         settings.ftp.maxConcurrentUploads,
         payloads.count
     )

     await withTaskGroup(of: Void.self) { group in
         var iterator = payloads.makeIterator()

         for _ in 0..<maxConcurrentUploads {
             if let payload = iterator.next() {
                 group.addTask {
                     await uploadOne(
                         payload,
                         app: app,
                         settings: settings,
                         progress: progress
                     )
                 }
             }
         }

         while await group.next() != nil {
             if Task.isCancelled { break }
             if let next = iterator.next() {
                 group.addTask {
                     await uploadOne(
                         next,
                         app:app,
                         settings: settings,
                         progress: progress
                     )
                 }
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
 
 */
