//
//  IGRecord.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2026-01-02.
//

import Foundation
import CoreGraphics

extension IGRecord {
    
    var design: IGDesignKey {
        get { IGDesignKey(rawValue: rawDesign) ?? .defaultValue }
        set { rawDesign = newValue.rawValue }
    }
    
    var theme: any IGTheme {
        get { design.theme(rawValue: rawTheme) ?? design.defaultTheme }
        set { rawTheme = newValue.rawValue }
    }
    
    var status: IGRecordStatus {
        get { IGRecordStatus(rawValue: rawStatus) ?? .defaultValue }
        set { rawStatus = newValue.rawValue }
    }
    
    var key: IHRecordKey {
        IHRecordKey(from: self)
    }
    
    var isQueued: Bool { status.isQueued }
    var isRendered: Bool { status.isRendered }
    var isUploaded: Bool { status.isUploaded }
    var isRenderedOrUploaded: Bool { status.isRenderedOrUploaded }
    var isArchived: Bool { status.isArchived }
    
    var isLatestRecord: Bool {
        guard let phrase else { return false }
        let pending = phrase.pendingRevision(for: key)
        let latest = phrase.latestRevision(for: key)
        
        return revision == (pending == latest ? latest : pending)
    }

    var isLatestRevision: Bool {
        guard let phrase else { return false }
        let latest = phrase.latestRevision(for: key)
        return revision == latest
    }

    var isLatestInOnline: Bool {
        guard let phrase,
              let latestUpload = phrase.latestUpload(for: key) else {
            return false
        }
        return revision == latestUpload
    }
    
    var title: String {
        design.imageTitle(for: self)
    }

    var descriptionText: String {
        design.imageDescription(for: self)
    }

    var fileName: String {
        design.imageFilename(for: self)
    }

    var versionInfo: String {
        "App: \(appInfo.fullVersion) | Template: \(design.id) | Image: \(revision.spelledOutRevision)"
    }

    var size: CGSize {
        CGSize(width: width, height: height)
    }
    
    var metadata: IGImageMetadata {
        IGImageMetadata(
            title: title,
            detailDescription: descriptionText,
            author: author,
            keywords: tagSnapshots.map(\.value),
            versionInfo: versionInfo
        )
    }
    
    @discardableResult
    func markAsQueuedForRender() -> Self {
        status = .queued
        dateRendered = nil
        renderDuration = nil
        dateUploaded = nil
        uploadDuration = nil
        failedMessage = nil
        return self
    }

    @discardableResult
    func markAsDrawing() -> Self {
        status = .drawing
        failedMessage = nil
        return self
    }

    @discardableResult
    func markAsSaving() -> Self {
        status = .saving
        failedMessage = nil
        return self
    }

    @discardableResult
    func markAsRendered(_ duration: TimeInterval) -> Self {
        dateRendered = .now
        renderDuration = duration

        // Replace old rendered versions with the same filename.
        phrase?.records
            .filter { $0.fileName == self.fileName && $0.isRendered }
            .forEach { $0.markAsReplacedInFolder() }

        status = .rendered
        failedMessage = nil
        phrase?.stepRevision(for: key)

        return self
    }

    @discardableResult
    func markAsReplacedInFolder() -> Self {
        status = .replacedInFolder
        failedMessage = nil
        return self
    }

    @discardableResult
    func markRenderAsFailed(_ message: String) -> Self {
        status = .failedRender
        failedMessage = message
        return self
    }

    @discardableResult
    func markAsUploading() -> Self {
        status = .uploading
        failedMessage = nil
        return self
    }

    @discardableResult
    func markAsUploaded(_ duration: TimeInterval) -> Self {
        dateUploaded = .now
        uploadDuration = duration

        phrase?.records
            .filter { $0.fileName == self.fileName && $0.isUploaded }
            .forEach { $0.markAsReplacedOnline() }

        status = .uploaded
        failedMessage = nil
        phrase?.updateUpload(for: key)

        return self
    }

    @discardableResult
    func markAsReplacedOnline() -> Self {
        status = .replacedOnline
        failedMessage = nil
        return self
    }

    @discardableResult
    func markUploadAsFailed(_ message: String) -> Self {
        status = .failedUpload
        failedMessage = message
        return self
    }
}
