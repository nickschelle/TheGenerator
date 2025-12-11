//
//  Date+DisplayString.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-11-08.
//

import Foundation

extension Date {

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
