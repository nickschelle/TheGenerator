//
//  IGTempTag.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-11-18.
//

import Foundation
import SwiftData


struct IGTempTag {

    var value: String
    var scope: IGTagScope
    var isPreset: Bool
    var linkCount: Int

    init(
        _ value: String,
        scope: IGTagScope,
        linkCount: Int = 0,
        isPreset: Bool = false
    ) {
        self.value = value
        self.scope = scope
        self.linkCount = linkCount
        self.isPreset = isPreset
    }
}

extension IGTempTag {
    
    var isShared: Bool { linkCount > 0 }
    
    init(
        from tag: IGTag,
        ignoring sourceID: UUID? = nil
    ) {
        self.value = tag.value
        self.scope = tag.scope
        self.isPreset = tag.isPreset

        let links = if let sourceID {
            tag.links.filter { $0.sourceID != sourceID }
        } else {
            tag.links
        }

        self.linkCount = links.count
    }
    
    /*
        init(from snapshot: IGTagSnapshot) {
            self.value = snapshot.value
            self.scope = snapshot.scope
            self.isPreset = snapshot.isPreset
            self.linkCount = 0
        }
    */
    func getTag(
        persisting: Bool = false,
        in context: ModelContext
    ) throws -> IGTag {
        let rawScope = scope.rawValue

        let descriptor = FetchDescriptor<IGTag>(
            predicate: #Predicate { tag in
                tag.value == value &&
                tag.rawScope == rawScope
            }
        )

        if let existing = try context.fetch(descriptor).first {
            return existing
        }

        let newTag = IGTag(value, scope: scope, isPreset: isPreset)

        if persisting {
            context.insert(newTag)
        }

        return newTag
    }
}

extension IGTempTag: Identifiable {
    var id: String { value }
}

extension IGTempTag: Hashable{
    func hash(into hasher: inout Hasher) {
        hasher.combine(value)
        hasher.combine(scope)
    }
}

extension IGTempTag: Equatable {
    static func == (lhs: IGTempTag, rhs: IGTempTag) -> Bool {
        lhs.value == rhs.value && lhs.scope == rhs.scope
    }
}

extension IGTempTag: IGTagRepresentable {}

extension IGTempTag: IGPrioritizable {}

