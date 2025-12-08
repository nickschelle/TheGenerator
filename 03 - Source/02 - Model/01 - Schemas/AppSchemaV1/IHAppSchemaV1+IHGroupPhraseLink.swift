//
//  IHAppSchemaV1+IHGroupPhraseLink.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-12-07.
//

import Foundation
import SwiftData

extension IHAppSchemaV1 {
    
    @Model
    final class IHGroupPhraseLink {
        
        var id: UUID = UUID()
        
        @Relationship(deleteRule: .nullify)
        var group: IHGroup? = nil
        
        @Relationship(deleteRule: .nullify)
        var phrase: IHPhrase? = nil
        
        var sortOrder: Int = 0
        
        init(
            group: IHGroup,
            phrase: IHPhrase,
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
