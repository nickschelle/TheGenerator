//
//  IGTag.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-12-08.
//

import Foundation
/*
extension IGTag {
    func isTagging(ignoring sourceID: UUID? = nil) -> Bool {
        guard let sourceID else {
            return !links.isEmpty
        }

        return links.contains { $0.sourceID != sourceID }
    }
    
    func taggedCount(ignoring sourceID: UUID? = nil) -> Int {
        guard let sourceID else {
            return links.count
        }
        return links.filter { $0.sourceID != sourceID }.count
    }
}
*/
extension IGTag {
    var scope: IGTagScope {
        get { IGTagScope(rawValue: rawScope) ?? .defaultValue }
        set { rawScope = newValue.rawValue }
    }
}

extension IGTag: IGDateStampable {}

extension IGTag: IGNormalizableString {

    static func normalizeForInput(_ value: String) -> String {
        normalizeTag(value, preserveTrailingSpace: true)
    }
    
    static func normalizeForSave(_ value: String) -> String {
        normalizeTag(value, preserveTrailingSpace: false)
    }
    
    private static func normalizeTag(
        _ value: String,
        preserveTrailingSpace: Bool
    ) -> String {
        
        guard !value.isEmpty else { return value }
        
        let hadTrailingSpace = value.last?.isWhitespace == true
        
        // --------------------------------------------
        // 1. Keep only letters, digits, allowed specials,
        //    whitespace, and allowed hyphens.
        // --------------------------------------------
        
        let filtered = value.compactMap { ch -> Character? in
            if ch.isLetter || ch.isNumber || ch.isWhitespace {
                return ch
            }
            if allowedSpecialCharacters.contains(ch) {
                return ch
            }
            if allowedHyphens.contains(ch) {
                return "-"         // normalize ALL hyphens here
            }
            return nil             // discard any other symbols
        }
        
        var result = String(filtered)
        
        // --------------------------------------------
        // 2. Collapse any sequence of whitespace to a single space
        // --------------------------------------------
        
        result = result
            .split(whereSeparator: { $0.isWhitespace })
            .joined(separator: " ")
        
        // --------------------------------------------
        // 3. Collapse multiple hyphens ("--") to single "-"
        // --------------------------------------------
        
        while result.contains("--") {
            result = result.replacingOccurrences(of: "--", with: "-")
        }
        
        // --------------------------------------------
        // 4. Lowercase the final output
        // --------------------------------------------
        
        result = result.lowercased()
        
        // --------------------------------------------
        // 5. Preserve trailing space during user editing
        // --------------------------------------------
        
        if preserveTrailingSpace, hadTrailingSpace {
            if !result.hasSuffix(" ") {
                result.append(" ")
            }
        }
        
        return result
    }
}
