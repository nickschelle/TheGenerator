//
//  IGValueDateStampable.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-11-15.
//

import Foundation

protocol IGValueDateStampable {

    var dateModified: Date { get set }
    mutating func touch()
}

extension IGValueDateStampable {

    mutating func touch() {
        dateModified = .now
    }
}
