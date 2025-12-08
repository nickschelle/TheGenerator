//
//  IHNormalization.swift
//  IHeartEverything
//
//  Created by Nick Schelle on 2025-11-20.
//

import Foundation

enum IHNormalization {

    // MARK: - Shared Allowed Characters
    
    static let allowedSpecialCharacters: Set<Character> = ["♥︎", "♥"]

    static let allowedHyphens: Set<Character> = [
        "-",            // hyphen-minus
        "‒",            // U+2012 figure dash
        "‐",            // U+2010 hyphen
        "-",            // U+2011 non-breaking hyphen
        "–",            // en dash
        "—"             // em dash
    ]

    // MARK: - Small Words for Group Title Case

    static let smallWords: Set<String> = [
        "a", "an", "the",
        "and", "but", "or", "nor", "for", "so", "yet",
        "as", "at", "by", "in", "of", "on", "per", "to",
        "via", "up", "upon", "off",
        "from", "into", "onto",
        "than", "that", "once", "when",
        "like", "near", "over", "past",
        "with"
    ]

    // MARK: - Public Model-Specific APIs

    /// Live updating inside a TextField
    static func input(_ value: String) -> String {
        normalizeSegments(
            value,
            preserveTrailingSpace: true,
            lowerSmallWords: true
        )
    }

    /// Final saved value
    static func save(_ value: String) -> String {
        normalizeSegments(
            value,
            preserveTrailingSpace: false,
            lowerSmallWords: true
        )
    }

    // MARK: - Core Segment-Based Normalizer

    static func normalizeSegments(
        _ value: String,
        preserveTrailingSpace: Bool,
        lowerSmallWords: Bool
    ) -> String {

        guard !value.isEmpty else { return value }

        let hadTrailingSpace = value.last == " "

        enum Segment: Equatable {
            case word(String)
            case space
            case hyphen
        }

        // --------------------------------------------
        // 1. Segment into words, spaces, and hyphens
        // --------------------------------------------
        var segments: [Segment] = []
        var currentWord = ""

        func flush() {
            if !currentWord.isEmpty {
                segments.append(.word(currentWord))
                currentWord.removeAll(keepingCapacity: true)
            }
        }

        for ch in value {
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

        var transformed: [Segment] = []
        var firstWordSeen = false

        for (index, seg) in segments.enumerated() {
            switch seg {

            case .word(let word):

                let isFirstWord = !firstWordSeen
                firstWordSeen = true

                // look at surrounding separators
                let prev = segments[..<index].last { if case .word = $0 { return false } else { return true } }
                let next = segments[(index+1)...].first { if case .word = $0 { return false } else { return true } }

                let prevIsSpace = (prev == .space)
                let nextIsSpace = (next == .space)

                let lower = word.lowercased()

                let shouldBeSmall =
                    lowerSmallWords &&
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
