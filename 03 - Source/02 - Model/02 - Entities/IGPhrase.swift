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
    
    func stepRevision(for key: IHRecordKey) {
        let id = key.rawID
        revisionMap[id] = pendingRevision(for: key)
    }

    func latestRevision(for key: IHRecordKey) -> Int {
        revisionMap[key.rawID] ?? -1
    }

    func pendingRevision(for key: IHRecordKey) -> Int {
        latestRevision(for: key) + 1
    }
    
    func updateUpload(for key: IHRecordKey) {
        let latest = latestRevision(for: key)
        uploadMap[key.rawID] = latest
    }

    func latestUpload(for key: IHRecordKey) -> Int? {
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
