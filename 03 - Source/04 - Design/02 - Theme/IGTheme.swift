//
//  IGTheme.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-12-17.
//

import Foundation

protocol IGTheme:
    Hashable,
    Identifiable,
    IGTagPresetable,
    Codable,
    RawRepresentable
where RawValue == String {
    var displayName: String { get }
}

extension IGTheme {
    var id: String { rawValue }
}
