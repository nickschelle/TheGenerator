//
//  IGDesignTheme.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-12-17.
//

import Foundation

protocol IGDesignTheme: RawRepresentable, CaseIterable, Hashable
where RawValue == String {
    var displayName: String { get }
    static var defaultTheme: Self { get }
    @MainActor var presetTags: Set<IGTag> { get }
}

extension IGDesignTheme {
    var id: String { rawValue }
}



