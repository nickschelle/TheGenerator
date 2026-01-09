//
//  IGRecord.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2026-01-02.
//

import Foundation

extension IGRecord {
    
    var design: IGDesignKey {
        get { IGDesignKey(rawValue: rawDesign) ?? .defaultValue }
        set { rawDesign = newValue.rawValue }
    }
    
    var Theme: any IGTheme {
        get { design.theme(rawValue: rawTheme) ?? design.defaultTheme }
        set { rawTheme = newValue.rawValue }
    }
    
    var status: IGRecordStatus {
        get { IGRecordStatus(rawValue: rawStatus) ?? .defaultValue }
        set { rawStatus = newValue.rawValue }
    }
}
    /*
         

         // MARK: - Computed Properties
         /// Template-specific display title.
         var title: String {
             template.title(from: self)
         }

         /// Template-specific description text.
         var descriptionText: String {
             template.description(from: self)
         }

         /// Template-specific filename (without extension).
         var fileName: String {
             template.fileName(from: self)
         }

         /// Textual representation of this record’s version for metadata.
         var versionInfo: String {
             "App: \(appInfo.fullVersion) | Template: \(template.id) | Image: \(revision.spelledOutRevision)"
         }

         /// Rendered size as a CoreGraphics size.
         var size: CGSize {
             CGSize(width: width, height: height)
         }

         /// Metadata passed to the renderer.
         var metadata: IHImageMetadata {
             IHImageMetadata(
                 title: title,
                 detailDescription: descriptionText,
                 author: author,
                 keywords: tags.map(\.value),
                 versionInfo: versionInfo
             )
         }

         /// Convenience: template × color × font key.
         var key: IHRecordKey {
             IHRecordKey(template: template, color: color, font: font)
         }


         // MARK: - Status Flags

         var isQueued: Bool { status.isQueued }
         var isRendered: Bool { status.isRendered }
         var isUploaded: Bool { status.isUploaded }
         var isRenderedOrUploaded: Bool { status.isRenderedOrUploaded }
         var isArchived: Bool { status.isArchived }


         // MARK: - Latest-State Helpers

         /// True if this record is the *current* record (latest pending or latest rendered)
         /// for its phrase/key.
         var isLatestRecord: Bool {
             guard let phrase else { return false }
             let pending = phrase.pendingRevision(for: key)
             let latest = phrase.latestRevision(for: key)

             // If there is no future pending slot, compare against latest.
             return revision == (pending == latest ? latest : pending)
         }

         /// True if this record holds the latest *rendered* revision for its key.
         var isLatestRevision: Bool {
             guard let phrase else { return false }
             let latest = phrase.latestRevision(for: key)
             return revision == latest
         }

         /// True if this record is the latest *uploaded* revision for its key.
         var isLatestInOnline: Bool {
             guard let phrase,
                   let latestUpload = phrase.latestUpload(for: key) else {
                 return false
             }
             return revision == latestUpload
         }
    */
