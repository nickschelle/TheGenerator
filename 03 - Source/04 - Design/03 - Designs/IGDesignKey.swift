//
//  IGDesignKey.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-12-27.
//

import Foundation

enum IGDesignKey: String, RawRepresentable, CaseIterable, Codable {
    case iHeartPhraseV1
    
    static var defaultValue: Self { .iHeartPhraseV1 }
}

extension IGDesignKey {
    var design: any IGDesign.Type {
        switch self {
        case .iHeartPhraseV1: IHeartPhraseDesignV1.self
        }
    }
    
    var displayName: String { design.displayName }
    var shortName: String { design.shortName }
    var themes: [any IGTheme] { design.themes }
    var presetTags: Set<IGTag> { design.presetTags }
    
    func format(_ phrase: String) -> String {
        design.format(phrase)
    }
}

extension IGDesignKey: Identifiable {
    var id: String { design.id }
}
