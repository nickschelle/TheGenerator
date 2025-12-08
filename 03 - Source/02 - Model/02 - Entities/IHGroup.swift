//
//  IHGroup.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-12-06.
//

import Foundation

extension IHGroup {
    var phrases: [IHPhrase] {
        phraseLinks.compactMap(\.phrase)
    }
}

extension IHGroup: IHDateStampable {}

extension IHGroup: IHOrderSortable {}

extension IHGroup: IHNormalizableString {

    static func normalize(_ value: String) -> String {
        IHNormalization.save(value)
    }
}
