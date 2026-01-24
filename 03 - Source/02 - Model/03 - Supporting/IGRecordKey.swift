//
//  IHRecordKey.swift
//  IHeartEverything
//
//  Created by Nick Schelle on 2025-11-19.
//

struct IHRecordKey: Hashable, Identifiable, CustomStringConvertible, Comparable {
    let designKey: IGDesignKey
    let themeID: String

    init(from record: IGRecord) {
        self.designKey = record.design
        self.themeID = record.rawTheme
    }

    init(designKey: IGDesignKey, theme: any IGDesignTheme) {
        self.designKey = designKey
        self.themeID = theme.id
    }
/*
    var theme: any IGDesignTheme {
        designKey.design.theme(rawValue: themeID) ?? designKey.design.defaultTheme
    }
*/
    var rawID: String {
        "\(designKey.rawValue)-\(themeID)"
    }

    var id: String { rawID }
    var description: String { rawID } // } displayValue() }
/*
    func displayValue(includeDesign: Bool = true) -> String {
        (includeDesign ? "\(designKey.displayName) " : "") + theme.displayName
    }
*/
    static func < (lhs: Self, rhs: Self) -> Bool {
        (lhs.designKey.rawValue, lhs.themeID) < (rhs.designKey.rawValue, rhs.themeID)
    }
}
