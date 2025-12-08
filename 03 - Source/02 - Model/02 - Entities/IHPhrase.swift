//
//  IHPhrase.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-12-01.
//

import Foundation

extension IHPhrase {
    var groups: [IHGroup] {
        groupLinks.compactMap(\.group)
    }
}

extension IHPhrase: IHDateStampable {}

extension IHPhrase: IHNormalizableString {

    static func normalize(_ value: String) -> String {
        IHNormalization.save(value)
    }
}
