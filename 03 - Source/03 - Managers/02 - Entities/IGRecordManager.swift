//
//  IGRecordManager.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-11-21.
//

import Foundation
import SwiftData

struct IGRecordManager {
    
    @discardableResult
    static func createPhraseRecords(
        for phrases: some Collection<IGPhrase>,
        with settings: IGAppSettings,
        in context: ModelContext
    ) throws -> [IGRecord] {
        
        var newRecords: [IGRecord] = []
        
        for phrase in phrases {
            
            var phraseDesignKeys = phrase.designKeys

            if let workspaceDesign = settings.workspace.workspace.designKey {
                phraseDesignKeys = phraseDesignKeys.intersection([workspaceDesign])
                guard !phraseDesignKeys.isEmpty else { continue }
            }
            
            let presetTags = IGTagManager.associatedPresetTags(
                for: phrase,
                with: settings
            )
            
            let customTags = try IGTagManager.associatedCustomTags(for: phrase, in: context)
            
            var associatedTags = presetTags.union(customTags)
            
            for designKey in phraseDesignKeys {
                
                let designConfig = settings.designConfigs[designKey] ?? designKey.loadConfig()
                
                let themes = designKey.themes.filter {
                    designConfig.activeThemeIDs.contains($0.id)
                }
                
                for theme in themes {
                    
                    let key = IHRecordKey(designKey: designKey, theme: theme)

                    associatedTags.formUnion(designKey.presetTags(using: theme))
                    let cleanedTags = IGTagManager.dedupeByPriority(associatedTags)
                    
                    let revision = phrase.pendingRevision(for: key)
                    
                    let appInfo = IGAppInfoSnapshot.current()

                    let record = IGRecord(
                        phrase: phrase,
                        author: settings.metadata.author,
                        tags: cleanedTags,
                        design: designKey,
                        theme: theme,
                        width: designConfig.width,
                        height: designConfig.height,
                        revision: revision,
                        appInfo: appInfo
                    )
                    
                    context.insert(record)

                    phrase.records
                        .filter { $0.key == key && $0.isQueued && $0 != record }
                        .forEach { context.delete($0) }

                    newRecords.append(record)
                  
                }
            }
            //Self.clearCache(for: phrase)
        }
        
        return newRecords
    }

    static func deleteRecords(
        _ records: some Collection<IGRecord>,
        with settings: IGAppSettings,
        in context: ModelContext
    ) throws {
        var affectedPhrases: [IGPhrase] = []
        
        for record in records {
            try deleteRenderedImageFromDisk(record, at: settings.location)
            if let phrase = record.phrase { affectedPhrases.append(phrase) }
            context.delete(record)
        }
        
        //affectedPhrases.forEach{ clearCache(for: $0) }
    }
    
    static func deleteRenderedImageFromDisk(_ record: IGRecord, at location: IGLocationConfig) throws {
        guard record.isLatestRevision else { return }

        guard let folderURL = location.startAccessing() else { return }
        defer { location.stopAccessing() }

        let fileURL = folderURL
            .appendingPathComponent(record.fileName)
            .appendingPathExtension("png")

        if !FileManager.default.fileExists(atPath: fileURL.path) {
            return
        }
        
        try FileManager.default.removeItem(at: fileURL)
    }
}
/*
let records: [IHRecord]
let phrase: IHPhrase
let includedKeys: Set<IHRecordKey>?

init(
    for records: [IHRecord]? = nil,
    of phrase: IHPhrase,
    includedKeys: Set<IHRecordKey>? = nil
) {
    let resolvedRecords = records ?? phrase.records

    // Validate phrase ownership
    if !resolvedRecords.allSatisfy({ $0.phrase?.id == phrase.id }) {
        print("❌ IHRecordManager.init — mixed phrases detected. Using phrase.records instead.")
        self.records = phrase.records
    } else {
        self.records = resolvedRecords
    }

    self.phrase = phrase
    self.includedKeys = includedKeys
}

mutating func byKey(for template: IHTemplateKey? = nil) -> [IHRecordKey : [IHRecord?]] {

    let full = Self.groupRecordsByKey(records, for: phrase, including: includedKeys)

    guard let template else { return full }
    return full.filter { $0.key.template == template }
}

mutating func latestByKey(
    for template: IHTemplateKey? = nil
) -> [IHRecordKey : IHRecord] {

    let padded = byKey(for: template)
    var result: [IHRecordKey : IHRecord] = [:]
    result.reserveCapacity(padded.count)

    for (key, revisions) in padded {
        if let pending = pendingRecord(for: key, in: revisions) {
            result[key] = pending
        } else if let latest = latestRecord(for: key, in: revisions) {
            result[key] = latest
        }
    }

    return result
}

mutating func latestRevisionByKey(
    for template: IHTemplateKey? = nil
) -> [IHRecordKey : IHRecord] {

    let padded = byKey(for: template)
    var result: [IHRecordKey : IHRecord] = [:]
    result.reserveCapacity(padded.count)

    for (key, revisions) in padded {
        if let latest = latestRecord(for: key, in: revisions) {
            result[key] = latest
        }
    }

    return result
}

mutating func latestUploadRevisionByKey(
    for template: IHTemplateKey? = nil
) -> [IHRecordKey : IHRecord] {

    let padded = byKey(for: template)
    var result: [IHRecordKey : IHRecord] = [:]
    result.reserveCapacity(padded.count)

    for (key, revisions) in padded {
        // Ask phrase which revision was uploaded
        guard let uploadedRevision = phrase.latestUpload(for: key) else {
            continue
        }

        // Safely fetch record at that revision index
        if let record = record(at: uploadedRevision, in: revisions) {
            result[key] = record
        }
    }

    return result
}

mutating func freshnessStatus(with settings: IHAppSettings) -> IHFreshness {
    let template = settings.image.template
    let requiredKeys = includedKeys ?? settings.image.recordKeys

    let latestRecords   = latestByKey(for: template)
    let latestRevisions = latestRevisionByKey(for: template)
    let latestUploads   = latestUploadRevisionByKey(for: template)

    var recordFresh = 0
    var renderFresh = 0
    var uploadFresh = 0
    let total = requiredKeys.count

    for key in requiredKeys {
        if latestRecords[key]?.isRecordFresh(settings) == true {
            recordFresh += 1
        }
        if latestRevisions[key]?.isRenderFresh(settings) == true {
            renderFresh += 1
        }
        if latestUploads[key]?.isUploadFresh(settings) == true {
            uploadFresh += 1
        }
    }

    return IHFreshness(
        records: .init(freshCount: recordFresh, total: total),
        renders: .init(freshCount: renderFresh, total: total),
        uploads: .init(freshCount: uploadFresh, total: total)
    )
}

private func record(
    at index: Int,
    in revisions: [IHRecord?]
) -> IHRecord? {
    guard index >= 0, index < revisions.count else {
        return nil
    }
    return revisions[index]
}

private func latestRecord(
    for key: IHRecordKey,
    in revisions: [IHRecord?]
) -> IHRecord? {
    let latest = phrase.latestRevision(for: key)
    return record(at: latest, in: revisions)
}

private func pendingRecord(
    for key: IHRecordKey,
    in revisions: [IHRecord?]
) -> IHRecord? {
    let pending = phrase.latestRevision(for: key) + 1
    return record(at: pending, in: revisions)
}
 
 private static var _byKeyCache: [UUID : [IHRecordKey : [IHRecord?]]] = [:]

 /// Clears cached grouping results for a given phrase.
 static func clearCache(for phrase: IHPhrase) {
     _byKeyCache.removeValue(forKey: phrase.id)
 }

 // MARK: - Static Grouping Helpers

 /// Groups records by `IHRecordKey` and pads each key’s revisions
 /// according to the phrase’s revision map.
 ///
 /// If `records` is `nil`, all records belonging to `phrase` are grouped.
 /// If `including` is provided, only those keys are returned—padded
 /// even when no matching records exist.
 ///
 /// Empty record sets are valid.
 ///
 /// - Parameters:
 ///   - records: Optional subset of records to group. Defaults to
 ///     `phrase.records`.
 ///   - phrase: The phrase that owns all grouped records.
 ///   - including: Optional set of `IHRecordKey`s controlling which
 ///     keys appear in the output.
 /// - Throws: `RecordError.mixedPhrases` if any provided record does not
 ///     belong to `phrase`.
 ///
 /// - Returns: A dictionary keyed by `IHRecordKey`, where each value is
 ///     an array of optional `IHRecord` indexed by revision number,
 ///     padded through the phrase’s pending revision.
 static func groupRecordsByKey(
     _ records: [IHRecord]? = nil,
     for phrase: IHPhrase,
     including recordKeys: Set<IHRecordKey>? = nil
 ) -> [IHRecordKey : [IHRecord?]] {

     // Return cached results if available
     if let existing = _byKeyCache[phrase.id] {
         return existing
     }

     let resolvedRecords = records ?? phrase.records

     // Validate that records all belong to phrase
     if !resolvedRecords.allSatisfy({ $0.phrase === phrase }) {
         print("❌ IHRecordManager.groupRecordsByKey — mixed phrases detected, returning empty dictionary.")
         return [:]
     }

     // Group by key
     let grouped = Dictionary(grouping: resolvedRecords, by: \.key)

     // Determine which keys should appear in output
     let targetKeys: Set<IHRecordKey> = recordKeys ?? Set(grouped.keys)

     var padded: [IHRecordKey : [IHRecord?]] = [:]
     padded.reserveCapacity(targetKeys.count)

     // Pad revision slots
     for key in targetKeys {
         let slotCount = phrase.pendingRevision(for: key) + 1
         var slots = Array<IHRecord?>(repeating: nil, count: slotCount)

         if let group = grouped[key] {
             for record in group where record.revision < slotCount {
                 slots[record.revision] = record
             }
         }

         padded[key] = slots
     }

     // Cache the completed result
     _byKeyCache[phrase.id] = padded

     return padded
 }


 // MARK: - Errors & Phrase Resolution

 enum RecordError: Error, LocalizedError {
     case mixedPhrases

     var errorDescription: String? {
         "All records must belong to the same phrase."
     }
 }
 
 */
