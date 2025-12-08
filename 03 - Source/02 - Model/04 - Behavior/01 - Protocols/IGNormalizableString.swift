//
//  IGNormalizableString.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-11-10.
//

import Foundation
import SwiftData

protocol IGNormalizableString {
    static var allowedSpecialCharacters: Set<Character> { get }
    static var allowedHyphens: Set<Character> { get }
    static var smallWords: Set<String> { get }
    static func normalizeForSave(_ value: String) -> String
    static func normalizeForInput(_ value: String) -> String
}

extension IGNormalizableString {
    
    static func normalizeForInput(_ string: String) -> String {
        normalizeSegments(
            string,
            preserveTrailingSpace: true
        )
    }
    
    static func normalizeForSave(_ string: String) -> String {
        normalizeSegments(
            string,
            preserveTrailingSpace: false
        )
    }
    
    static var allowedSpecialCharacters: Set<Character> { ["♥︎", "♥"] }

    static var allowedHyphens: Set<Character> { [
        "-",     // U+002D hyphen-minus
        "‐",     // U+2010 hyphen
        "-",     // U+2011 non-breaking hyphen (this is different)
        "‒",     // U+2012 figure dash
        "–",     // U+2013 en dash
        "—"      // U+2014 em dash
    ] }

    // MARK: - Small Words for Group Title Case

    static var smallWords: Set<String> {[
        "a", "an", "the",
        "and", "but", "or", "nor", "for", "so", "yet",
        "as", "at", "by", "in", "of", "on", "per", "to",
        "via", "up", "upon", "off",
        "from", "into", "onto",
        "than", "that", "once", "when",
        "like", "near", "over", "past",
        "with"
    ]}
    
    private static func normalizeSegments(
        _ string: String,
        preserveTrailingSpace: Bool
    ) -> String {

        guard !string.isEmpty else { return string }

        let hadTrailingSpace = string.last == " "

        // --------------------------------------------
        // 1. Segment into words, spaces, and hyphens
        // --------------------------------------------
        var segments: [IGNormalizationSegment] = []
        var currentWord = ""

        func flush() {
            if !currentWord.isEmpty {
                segments.append(.word(currentWord))
                currentWord.removeAll(keepingCapacity: true)
            }
        }

        for ch in string {
            if ch.isLetter || ch.isNumber || allowedSpecialCharacters.contains(ch) {
                currentWord.append(ch)
            }
            else if ch == " " {
                flush()
                if segments.last != .space { segments.append(.space) }
            }
            else if allowedHyphens.contains(ch) {
                flush()
                if segments.last != .hyphen { segments.append(.hyphen) }
            }
            else {
                // any other symbol acts like a space
                flush()
                if segments.last != .space { segments.append(.space) }
            }
        }
        flush()

        if segments.isEmpty {
            return preserveTrailingSpace && hadTrailingSpace ? " " : ""
        }

        // --------------------------------------------
        // 2. Transform words to correct casing
        // --------------------------------------------
        func isAcronym(_ word: String) -> Bool {
            word.count >= 2 &&
            word == word.uppercased() &&
            word.range(of: "[A-Z]", options: .regularExpression) != nil
        }

        var transformed: [IGNormalizationSegment] = []
        var firstWordSeen = false

        for (index, seg) in segments.enumerated() {
            switch seg {

            case .word(let word):

                let isFirstWord = !firstWordSeen
                firstWordSeen = true

                // look at surrounding separators
                let prev = segments[..<index].last(where: {
                    if case .word = $0 { return false } else { return true }
                })
                let next = segments[(index+1)...].first { if case .word = $0 { return false } else { return true } }

                let prevIsSpace = (prev == .space)
                let nextIsSpace = (next == .space)

                let lower = word.lowercased()

                let shouldBeSmall =
                    !isFirstWord &&
                    prevIsSpace &&
                    nextIsSpace &&
                    smallWords.contains(lower)

                let newWord: String
                if isAcronym(word) {
                    newWord = word
                } else if shouldBeSmall {
                    newWord = lower
                } else {
                    if let f = word.first {
                        newWord = String(f).uppercased() + word.dropFirst().lowercased()
                    } else {
                        newWord = word
                    }
                }

                transformed.append(.word(newWord))

            case .space:
                if transformed.last != .space { transformed.append(.space) }

            case .hyphen:
                if transformed.last != .hyphen { transformed.append(.hyphen) }
            }
        }

        // --------------------------------------------
        // 3. Join result
        // --------------------------------------------
        var result = ""

        for seg in transformed {
            switch seg {
            case .word(let w): result.append(w)
            case .space:       result.append(" ")
            case .hyphen:      result.append("-")
            }
        }
        
        // Remove accidental leading spaces
        while result.first == " " {
            result.removeFirst()
        }

        // 4. Handle trailing spaces
        if preserveTrailingSpace {
            if hadTrailingSpace && !result.hasSuffix(" ") {
                result.append(" ")
            }
        } else {
            while result.last == " " {
                result.removeLast()
            }
        }

        return result
    }
}

enum IGNormalizationSegment: Equatable {
    case word(String)
    case space
    case hyphen
}

