//
//  IGAppSchemaV1+IGSourceTagLink.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-10-09.
//

import Foundation
import SwiftData

extension IGAppSchemaV1 {
    @Model
    final class IGSourceTagLink {

        var id: UUID = UUID()
        var sourceID: UUID = UUID()
        var rawSourceScope: String = IGTagScope.defaultValue.rawValue
    
        @Relationship(deleteRule: .nullify)
        var tag: IGTag? = nil
        
        init(
            sourceScope: IGTagScope,
            sourceID: UUID? = nil,
            tag: IGTag,
            id: UUID = UUID()
        ) {
            self.id = id
            self.rawSourceScope = sourceScope.rawValue
            self.sourceID = sourceID ?? sourceScope.id
            self.tag = tag
        }
    }
}
