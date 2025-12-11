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
