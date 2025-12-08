//
//  IHGroup.swift
//  IHeartEverything
//
//  Created by Nick Schelle on 2025-09-21.
//

import Foundation
import SwiftData

extension IHAppSchemaV1 {
    @Model
    final class IHGroup {
        
        var id: UUID = UUID()
        var name: String = ""
        var sortOrder: Int = 0
        var descriptionBlock: String = ""
        var dateCreated: Date = Date.now
        var dateModified: Date = Date.now
        
        init(
            _ name: String,
            id: UUID = UUID(),
            sortOrder: Int = 0,
            descriptionBlock: String = "",
            dateCreated: Date = .now,
            dateModified: Date = .now
        ) {
            self.id = id
            self.name = name
            self.sortOrder = sortOrder
            self.descriptionBlock = descriptionBlock
            self.dateCreated = dateCreated
            self.dateModified = dateModified
        }
    }
}
