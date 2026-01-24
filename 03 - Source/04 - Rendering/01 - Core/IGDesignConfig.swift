//
//  IGDesignConfig.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2026-01-05.
//

import Foundation

struct IGDesignConfig: Codable, Sendable, Equatable, IGValueDateStampable {

    var activeThemeIDs: Set<String> = [] {
        didSet {
            if activeThemeIDs != oldValue { touch() }
        }
    }
    var width: Int = 4500 {
        didSet {
            if width != oldValue { touch() }
        }
    }
    var height: Int = 4500 {
        didSet {
            if height != oldValue { touch() }
        }
    }
    var dateModified: Date = .now
    
    init<Design: IGDesign>(for design: Design.Type) {
        self.activeThemeIDs = Set(design.themes.map(\.rawValue))
        self.width = 4500
        self.height = 4500
        self.dateModified = .now
    }
    
    func displayValues<Design: IGDesign>(for design: Design.Type) -> String {
        let themes = displayActiveThemes(for: design)

        return "\(width)px × \(height)px | \(themes)"
    }

    var displaySize: String {
        "\(width)px × \(height)px"
    }
    
    func displayActiveThemes<Design: IGDesign>(for design: Design.Type) -> String {
        activeThemeIDs
           .compactMap { try? design.theme(rawValue: $0).displayName }
           .joined(separator: ", ")
    }
    
    func displayActiveThemeCount<Design: IGDesign>(for design: Design.Type) -> String {
        "\(activeThemeIDs.count)/\(design.themes.count)"
    }
}
