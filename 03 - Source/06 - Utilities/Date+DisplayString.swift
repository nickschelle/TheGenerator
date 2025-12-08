//
//  Date+DisplayString.swift
//  IHeartEverything
//
//  Created by Nick Schelle on 2025-11-08.
//

import Foundation

// MARK: - UI-Friendly Date Formatting

extension Date {
    /// Returns a concise, user-facing date string optimized for UI display.
    ///
    /// Examples:
    /// ```
    /// Today, 3:45 PM
    /// Yesterday, 9:10 AM
    /// Nov 5, 2025, 7:30 PM
    /// ```
    var displayString: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(self) {
            return "Today, " + formatted(date: .omitted, time: .shortened)
        } else if calendar.isDateInYesterday(self) {
            return "Yesterday, " + formatted(date: .omitted, time: .shortened)
        } else {
            return formatted(date: .abbreviated, time: .shortened)
        }
    }
}
