//
//  IGDateStampable.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-11-15.
//

import Foundation
import SwiftData

protocol IGDateStampable: PersistentModel {

    var dateModified: Date { get set }
    func touch()
}

extension IGDateStampable {

    func touch() {
        dateModified = .now
    }
}
