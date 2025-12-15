//
//  ModelContext+IGTag.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-11-17.
//

import Foundation
import SwiftData

// MARK: - Tag Convenience Fetches

extension ModelContext {

    func tags(for source: some IGTaggable) throws -> [IGTag] {
        try tagLinks(for: source).compactMap(\.tag)
    }
    
    func tags(for identities: Set<IGTaggableIdentity>) throws -> [IGTag] {
        try tagLinks(for: identities).compactMap(\.tag)
    }

    func tags(at scope: IGTagScope) throws -> [IGTag] {
        try tagLinks(at: scope).compactMap(\.tag)
    }
}
