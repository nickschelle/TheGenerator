//
//  IGAppSchemaV1+IGGroupPhraseLink.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-12-07.
//

import Foundation
import SwiftData

extension IGAppSchemaV1 {
    
    @Model
    final class IGGroupPhraseLink {
        
        var id: UUID = UUID()
        
        @Relationship(deleteRule: .nullify)
        var group: IGGroup? = nil
        
        @Relationship(deleteRule: .nullify)
        var phrase: IGPhrase? = nil
        
        var sortOrder: Int = 0
        
        init(
            group: IGGroup,
            phrase: IGPhrase,
            sortOrder: Int = 0,
            id: UUID = UUID()
        ) {
            self.id = id
            self.group = group
            self.phrase = phrase
            self.sortOrder = sortOrder
        }
    }
}
