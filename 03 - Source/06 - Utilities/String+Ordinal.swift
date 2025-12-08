//
//  String+Ordinal.swift
//  IHeartEverything
//
//  Created by Nick Schelle on 2025-10-10.
//
import Foundation

extension Int {
    
    var spelledOutRevision: String {
        switch self {
        case -1:
            return "Unrendered"
        case 0:
            return "Original"
        default:
            return "\(self.spelledOutOrdinal) Revision"
        }
    }

    /// Full spelled-out ordinal for 1–100.
    /// For anything above 100, falls back to a numeric ordinal (e.g. "101st").
    var spelledOutOrdinal: String {
        let value = self

        // Negative values
        if value < 0 {
            return "minus " + (-value).spelledOutOrdinal
        }

        // Spelled-out for 1–100
        if let word = Self.spelledOutOrdinals[value] {
            return word
        }

        // Fallback to numeric ordinal
        return self.ordinal
    }

    /// Numeric ordinal using NumberFormatter ("1st", "2nd", "3rd", "4th", ...)
    var ordinal: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }

    // MARK: - Static lookup table for 1–100 spelled-out ordinals

    private static let spelledOutOrdinals: [Int: String] = [
        1: "First", 2: "Second", 3: "Third", 4: "Fourth", 5: "Fifth",
        6: "Sixth", 7: "Seventh", 8: "Eighth", 9: "Ninth", 10: "Tenth",
        11: "Eleventh", 12: "Twelfth", 13: "Thirteenth", 14: "Fourteenth",
        15: "Fifteenth", 16: "Sixteenth", 17: "Seventeenth", 18: "Eighteenth",
        19: "Nineteenth", 20: "Twentieth",
        21: "Twenty-First", 22: "Twenty-Second", 23: "Twenty-Third",
        24: "Twenty-Fourth", 25: "Twenty-Fifth", 26: "Twenty-Sixth",
        27: "Twenty-Seventh", 28: "Twenty-Eighth", 29: "Twenty-Ninth",
        30: "Thirtieth",
        31: "Thirty-First", 32: "Thirty-Second", 33: "Thirty-Third",
        34: "Thirty-Fourth", 35: "Thirty-Fifth", 36: "Thirty-Sixth",
        37: "Thirty-Seventh", 38: "Thirty-Eighth", 39: "Thirty-Ninth",
        40: "Fortieth",
        41: "Forty-First", 42: "Forty-Second", 43: "Forty-Third",
        44: "Forty-Fourth", 45: "Forty-Fifth", 46: "Forty-Sixth",
        47: "Forty-Seventh", 48: "Forty-Eighth", 49: "Forty-Ninth",
        50: "Fiftieth",
        51: "Fifty-First", 52: "Fifty-Second", 53: "Fifty-Third",
        54: "Fifty-Fourth", 55: "Fifty-Fifth", 56: "Fifty-Sixth",
        57: "Fifty-Seventh", 58: "Fifty-Eighth", 59: "Fifty-Ninth",
        60: "Sixtieth",
        61: "Sixty-First", 62: "Sixty-Second", 63: "Sixty-Third",
        64: "Sixty-Fourth", 65: "Sixty-Fifth", 66: "Sixty-Sixth",
        67: "Sixty-Seventh", 68: "Sixty-Eighth", 69: "Sixty-Ninth",
        70: "Seventieth",
        71: "Seventy-First", 72: "Seventy-Second", 73: "Seventy-Third",
        74: "Seventy-Fourth", 75: "Seventy-Fifth", 76: "Seventy-Sixth",
        77: "Seventy-Seventh", 78: "Seventy-Eighth", 79: "Seventy-Ninth",
        80: "Eightieth",
        81: "Eighty-First", 82: "Eighty-Second", 83: "Eighty-Third",
        84: "Eighty-Fourth", 85: "Eighty-Fifth", 86: "Eighty-Sixth",
        87: "Eighty-Seventh", 88: "Eighty-Eighth", 89: "Eighty-Ninth",
        90: "Ninetieth",
        91: "Ninety-First", 92: "Ninety-Second", 93: "Ninety-Third",
        94: "Ninety-Fourth", 95: "Ninety-Fifth", 96: "Ninety-Sixth",
        97: "Ninety-Seventh", 98: "Ninety-Eighth", 99: "Ninety-Ninth",
        100: "One Hundredth"
    ]
}
