//
//  ModelContext+IGSourceTagLink.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-11-17.
//

import Foundation
import SwiftData

extension ModelContext {

    func tagLinks(for source: some IGTaggable) throws -> [IGSourceTagLink] {
        let id = source.id
        let rawScope = type(of: source).tagScope.rawValue
        let descriptor = FetchDescriptor<IGSourceTagLink>(
            predicate: #Predicate { link in
                link.sourceID == id &&
                link.rawSourceScope == rawScope
            }
        )
        return try fetch(descriptor)
    }

    func tagLinks(at scope: IGTagScope) throws -> [IGSourceTagLink] {
        let id = scope.id
        let rawScope = scope.rawValue
        let descriptor = FetchDescriptor<IGSourceTagLink>(
            predicate: #Predicate { link in
                link.sourceID == id &&
                link.rawSourceScope == rawScope
            }
        )
        return try fetch(descriptor)
    }
    
    private func _tagLinkDescriptor(id: UUID, scope: IGTagScope)
        -> FetchDescriptor<IGSourceTagLink>
    {
        FetchDescriptor<IGSourceTagLink>(
            predicate: #Predicate { link in
                link.sourceID == id &&
                link.rawSourceScope == scope.rawValue
            }
        )
    }
}
