//
//  IHAppSchemaV1+IHPhrase.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-09-21.
//

import Foundation
import SwiftData

extension IHAppSchemaV1 {
    
    @Model
    final class IHPhrase {
        
        var id: UUID = UUID()
        var value: String = ""
        var descriptionBlock: String = ""
        var dateCreated: Date = Date.now
        var dateModified: Date = Date.now
        
        private(set) var revisionMap: [String: Int] = [:]
        private(set) var uploadMap: [String: Int] = [:]
        
        @Relationship(deleteRule: .cascade, inverse: \IHGroupPhraseLink.phrase)
        var groupLinks: [IHGroupPhraseLink] = []
        
        init(
            _ value: String,
            id: UUID = UUID(),
            descriptionBlock: String = "",
            revisionMap: [String : Int] = [:],
            uploadMap: [String : Int] = [:],
            dateCreated: Date = .now,
            dateModified: Date = .now
        ) {
            self.id = id
            self.value = value
            self.descriptionBlock = descriptionBlock
            self.revisionMap = revisionMap
            self.uploadMap = uploadMap
            self.dateCreated = dateCreated
            self.dateModified = dateModified
        }
    }
}
