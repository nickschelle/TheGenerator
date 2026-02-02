//
//  IGPhrase.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-12-01.
//

import Foundation

extension IGPhrase {
    var groups: [IGGroup] {
        groupLinks.compactMap(\.group)
    }
    
    var designKeys: Set<IGDesignKey> {
        Set(designLinks.map(\.designKey))
    }
    
    var isEditable: Bool {
        revisionMap.isEmpty && records.isEmpty
    }
    
    func stepRevision(for key: IGRecordKey) {
        let id = key.rawID
        revisionMap[id] = pendingRevision(for: key)
    }

    func latestRevision(for key: IGRecordKey) -> Int {
        revisionMap[key.rawID] ?? -1
    }

    func pendingRevision(for key: IGRecordKey) -> Int {
        latestRevision(for: key) + 1
    }
    
    func updateUpload(for key: IGRecordKey) {
        let latest = latestRevision(for: key)
        uploadMap[key.rawID] = latest
    }

    func latestUpload(for key: IGRecordKey) -> Int? {
        uploadMap[key.rawID]
    }
}

extension IGPhrase: IGTagPresetable {
    var presetTags: Set<IGTag> {
        [IGTag(normalizing: value, scope: .phrase, isPreset: true)]
    }
}

extension IGPhrase: IGTaggable {
    static var tagScope: IGTagScope { .phrase }
}

extension IGPhrase: IGDateStampable {}

extension IGPhrase: IGNormalizableString {}
