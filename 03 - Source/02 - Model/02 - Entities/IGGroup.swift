//
//  IGGroup.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-12-06.
//

import Foundation

extension IGGroup {
    var phrases: [IGPhrase] {
        phraseLinks.compactMap(\.phrase)
    }
}

extension IGGroup: IGTagPresetable {
    var presetTags: Set<IGTag> {
        [IGTag(normalizing: name, scope: .group, isPreset: true)]
    }
}

extension IGGroup: IGTaggable {
    static var tagScope: IGTagScope { .group }
}


extension IGGroup: IGDateStampable {}

extension IGGroup: IGOrderSortable {}

extension IGGroup: IGNormalizableString {}
