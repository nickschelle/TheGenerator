//
//  IGTheme.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-12-17.
//

import Foundation

protocol IGTheme: Hashable, Identifiable, IGTagPresetable {
    var displayName: String { get }
}

extension IGTheme
where Self: RawRepresentable, RawValue == String {

    var id: String { rawValue }
}
