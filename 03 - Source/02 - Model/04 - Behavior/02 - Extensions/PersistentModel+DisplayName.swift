//
//  PersistentModel+DisplayName.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-10-09.
//

import Foundation
import SwiftData

extension PersistentModel {
    
    static var displayName: String {
        String(describing: Self.self)
            .replacingOccurrences(of: "^IG", with: "", options: .regularExpression)
            .capitalized
    }

    static func displayName(with count: Int, includeNumberBelowTwo: Bool = true) -> String {
        let name = count == 1 ? displayName : displayName.pluralized()
        let countPrefix = (count > 1 || includeNumberBelowTwo) ? "\(count) " : ""
        return countPrefix + name
    }
}
