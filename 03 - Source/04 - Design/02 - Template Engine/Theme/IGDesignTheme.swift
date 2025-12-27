//
//  IGTemplateColorRole.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-12-17.
//

import Foundation

protocol IGDesignTheme: Hashable, Identifiable, RawRepresentable, CaseIterable, IGTagPresetable
where RawValue == String {
    associatedtype Role: IGDesignRole
    func value(
        _ attribute: IGDesignAttribute,
        for role: Role
    ) -> IGDesignAttributeValue
    var displayName: String { get }
}

extension IGDesignTheme {
    var id: String { rawValue }
}

extension IGDesignTheme {
    
    func color(for role: Role) -> IGColor {
        guard case .color(let value) = value(.color, for: role) else {
            preconditionFailure("Expected color for \(role)")
        }
        return value
    }
    
    func font(for role: Role) -> IGFont {
        guard case .font(let value) = value(.font, for: role) else {
            preconditionFailure("Expected color for \(role)")
        }
        return value
    }
}



