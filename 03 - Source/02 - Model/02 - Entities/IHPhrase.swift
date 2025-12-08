//
//  IHPhrase.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-12-01.
//

import Foundation

extension IHPhrase: IHDateStampable {}

extension IHPhrase: IHNormalizableString {

    static func normalize(_ value: String) -> String {
        IHNormalization.save(value)
    }
}
