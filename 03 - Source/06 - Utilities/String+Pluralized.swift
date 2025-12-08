//
//  String+Pluralized.swift
//  IHeartEverything
//
//  Created by Nick Schelle on 2025-10-09.
//

import Foundation

// MARK: - String+Pluralized
//
// Provides lightweight, human-friendly pluralization for English words.
// Handles common English suffix rules and preserves capitalization style.
//

extension String {

    /// Returns a pluralized version of the string using simple English rules.
    ///
    /// Examples:
    /// ```swift
    /// "cat".pluralized()   // → "cats"
    /// "bus".pluralized()   // → "buses"
    /// "party".pluralized() // → "parties"
    /// "quiz".pluralized()  // → "quizzes"
    /// "BUS".pluralized()   // → "BUSES"
    /// ```
    ///
    /// - Note: This is intentionally lightweight and not locale-aware.
    /// - Returns: A pluralized string with capitalization preserved.
    func pluralized() -> String {
        guard !isEmpty else { return self }

        // Determine capitalization style once
        let isAllCaps = allSatisfy(\.isUppercase)

        // Efficient helper for casing suffixes
        @inline(__always)
        func suffix(_ s: StaticString) -> String {
            isAllCaps ? s.description.uppercased() : s.description
        }

        let lower = self.lowercased()

        // MARK: - "y" → "ies" rule (consonant + y)
        if lower.hasSuffix("y"), count > 1 {
            let beforeY = self[index(endIndex, offsetBy: -2)]
            if !"aeiouAEIOU".contains(beforeY) {
                return dropLast() + suffix("ies")
            }
        }

        // MARK: - "es" rules (s, x, ch, sh)
        if lower.hasSuffix("s")
            || lower.hasSuffix("x")
            || lower.hasSuffix("ch")
            || lower.hasSuffix("sh") {
            return self + suffix("es")
        }

        // MARK: - "z" → "zes"
        if lower.hasSuffix("z") {
            return self + suffix("zes")
        }

        // MARK: - Default "s"
        return self + suffix("s")
    }
}
