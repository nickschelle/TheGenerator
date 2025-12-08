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

extension IGGroup: IGDateStampable {}

extension IGGroup: IGOrderSortable {}

extension IGGroup: IGNormalizableString {}
