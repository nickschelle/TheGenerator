//
//  IHNormalizableString.swift
//  IHeartEverything
//
//  Created by Nick Schelle on 2025-11-10.
//

import Foundation
import SwiftData

protocol IHNormalizableString {
    static func normalize(_ value: String) -> String
}

extension IHNormalizableString {

    static func normalize(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .capitalized
    }
}
