//
//  String+CaseFormatting.swift
//  IHeartEverything
//
//  Created by Nick Schelle on 2025-10-09.
//

import Foundation

// MARK: - String+CaseFormatting
//
// Provides consistent normalization and case transformation utilities
// for converting between camelCase, PascalCase, Title Case, and
// other mixed input formats.
//
// Handles Unicode clusters properly and preserves leading/trailing
// whitespace for text fields.
//

extension String {

    // MARK: - Allowed Characters

    /// Special characters treated as standalone tokens.
    static let allowedSpecialCharacters: Set<Character> = ["♥︎", "♥"]


    // MARK: - CamelCase and PascalCase Spacing

    /// Inserts spaces between lowercase → uppercase transitions.
    ///
    /// Example: "usCities" → "us Cities"
    private var camelBreaksInserted: String {
        reduce(into: "") { result, character in
            if let lastCharacter = result.last,
               lastCharacter.isLowercase,
               character.isUppercase
            {
                result.append(" ")
            }

            result.append(character)
        }
    }


    // MARK: - Acronym Detection

    /// Returns true if the string is an acronym (all uppercase, at least 2 letters).
    private var isAcronym: Bool {
        count >= 2 &&
        self == uppercased() &&
        range(of: "[A-Z]", options: .regularExpression) != nil
    }


    // MARK: - Tokenization

    /// Splits the string into word tokens, respecting:
    /// - camelCase breaks
    /// - PascalCase breaks
    /// - underscores, punctuation, mixed whitespace
    /// - standalone allowed symbols (♥︎)
    var wordTokens: [String] {
        var tokens: [String] = []
        var currentToken = ""

        for character in camelBreaksInserted {
            switch character {

            // Letters and numbers form part of the current token
            case _ where character.isLetter || character.isNumber:
                currentToken.append(character)

            // Special allowed symbols form their own tokens
            case _ where Self.allowedSpecialCharacters.contains(character):
                if !currentToken.isEmpty {
                    tokens.append(currentToken)
                    currentToken.removeAll(keepingCapacity: true)
                }
                tokens.append(String(character))

            // Any other separator finalizes the current token
            default:
                if !currentToken.isEmpty {
                    tokens.append(currentToken)
                    currentToken.removeAll(keepingCapacity: true)
                }
            }
        }

        if !currentToken.isEmpty {
            tokens.append(currentToken)
        }

        return tokens
    }


    // MARK: - Whitespace Preservation

    private var leadingWhitespace: String {
        String(prefix(while: \.isWhitespace))
    }

    private var trailingWhitespace: String {
        String(reversed().prefix(while: \.isWhitespace).reversed())
    }


    // MARK: - Title Case (Acronym-Aware)

    /// Capitalizes each token, except tokens recognized as acronyms.
    ///
    /// Examples:
    /// - "us cities" → "Us Cities"
    /// - "US cities" → "US Cities"
    /// - "FTP server" → "FTP Server"
    var titleCased: String {
        let tokens = wordTokens
        guard !tokens.isEmpty else { return self }

        let lowercaseWords: Set<String> = [
            "a", "an", "the",
            "and", "but", "or", "nor",
            "as", "at", "by", "for", "from",
            "in", "into", "of", "on", "onto",
            "per", "to", "via", "with"
        ]

        let lastIndex = tokens.count - 1

        let transformed = tokens.enumerated().map { index, token in

            // Keep acronyms uppercase always
            if token.isAcronym { return token }

            let lower = token.lowercased()

            // First or last word → always capitalized
            if index == 0 || index == lastIndex {
                return lower.capitalized
            }

            // Middle: lowercase short words
            if lowercaseWords.contains(lower) {
                return lower
            }

            // Normal capitalized word
            return lower.capitalized
        }

        return leadingWhitespace + transformed.joined(separator: " ") + trailingWhitespace
    }


    // MARK: - camelCase (first token lowercased)

    /// Converts into camelCase.
    ///
    /// - "Funny Cats" → "funnyCats"
    /// - "US Cities" → "usCities" (acronym lowered)
    /// - "FTP Server" → "ftpServer" (not preserved)
    var camelCased: String {
        let tokens = wordTokens
        guard let firstToken = tokens.first else { return self }

        let transformedFirstToken = firstToken.lowercased()

        let transformedRemainingTokens = tokens.dropFirst().map { token in
            token.isAcronym ? token : token.capitalized
        }

        return leadingWhitespace +
        ([transformedFirstToken] + transformedRemainingTokens).joined() +
        trailingWhitespace
    }


    // MARK: - PascalCase

    /// Converts into PascalCase.
    ///
    /// - "funny cats" → "FunnyCats"
    /// - "US cities" → "USCities" (acronym preserved)
    /// - "FTP server" → "FTPServer"
    var pascalCased: String {
        leadingWhitespace +
        wordTokens.map { token in
            token.isAcronym ? token : token.capitalized
        }
        .joined() +
        trailingWhitespace
    }


    // MARK: - Capitalized Initials

    /// Example:
    /// - "funny cats" → "FC"
    /// - "US cities" → "USC"
    var capitalizedInitials: String {
        leadingWhitespace +
        wordTokens.compactMap { token in
            token.first?.uppercased()
        }.joined() +
        trailingWhitespace
    }
}
