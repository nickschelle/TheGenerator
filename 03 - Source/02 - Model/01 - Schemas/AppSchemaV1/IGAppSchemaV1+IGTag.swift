//
//  IGAppSchemaV1+IGTag.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-12-08.
//

import Foundation
import SwiftData

extension IGAppSchemaV1 {
    
    @Model
    final class IGTag {

        var id: UUID = UUID()
        var value: String = ""
        var dateCreated: Date = Date.now
        var dateModified: Date = Date.now
        var rawScope: String = IGTagScope.defaultValue.rawValue
        var isPreset: Bool = false

        init(
            _ value: String,
            id: UUID = UUID(),
            scope: IGTagScope = .defaultValue,
            isPreset: Bool = false,
            dateCreated: Date = .now,
            dateModified: Date = .now
        ) {
            self.id = id
            self.value = value
            self.rawScope = scope.rawValue
            self.isPreset = isPreset
            self.dateCreated = dateCreated
            self.dateModified = dateModified
        }
    }
}
