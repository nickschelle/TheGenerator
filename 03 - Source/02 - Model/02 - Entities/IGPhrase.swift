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

extension IGPhrase: IGDateStampable {}

extension IGPhrase: IGNormalizableString {}
