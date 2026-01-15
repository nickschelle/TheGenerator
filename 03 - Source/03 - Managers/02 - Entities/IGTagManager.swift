//
//  IGTagManager.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-12-08.
//

import Foundation
import SwiftData

enum IGTagManager {
    
    @discardableResult
    static func update(
        _ tag: IGTag,
        to newValue: String,
        in context: ModelContext
    ) throws -> IGTag {

        let normalized = IGTag.normalizeForSave(newValue)
        guard normalized != tag.value else { return tag }

        let rawScope = tag.scope.rawValue

        let descriptor = FetchDescriptor<IGTag>(
            predicate: #Predicate {
                $0.value == normalized &&
                $0.rawScope == rawScope
            }
        )

        if let existing = try context.fetch(descriptor).first {

            for link in tag.links {
                let exists = existing.links.contains {
                    $0.sourceID == link.sourceID &&
                    $0.rawSourceScope == link.rawSourceScope
                }

                if !exists {
                    let newLink = IGSourceTagLink(
                        sourceScope: link.sourceScope,
                        sourceID: link.sourceID,
                        tag: existing
                    )
                    context.insert(newLink)
                }

                context.delete(link)
            }

            existing.touch()
            context.delete(tag)

            return existing
        }

        tag.value = normalized
        tag.touch()
        return tag
    }
    
    static func remove(
        _ tag: IGTag,
       // with settings: IGAppSettings,
        in context: ModelContext
    ) throws {

        let ids: Set<UUID> = Set(tag.links.compactMap(\.sourceID))

        switch tag.scope {

        case .phrase:
            let descriptor = FetchDescriptor<IGPhrase>(predicate: #Predicate {
                ids.contains($0.id)
            })
            
            let all = try context.fetch(descriptor)
            all.forEach { $0.touch() }

            
        
        case .group:
            let descriptor = FetchDescriptor<IGGroup>(predicate: #Predicate {
                ids.contains($0.id)
            })
            
            let all = try context.fetch(descriptor)
            all.forEach { $0.touch() }
        /*
        case .defaults:
            // Touching settings defaults does not use SwiftData —
            // so simply resave the settings to bump its timestamp.
            settings.touchDefaultTags()
            settings.saveDefaultTags()
         */
        default:
            break
        }

        for link in tag.links {
            context.delete(link)
        }

        context.delete(tag)
    }
    
    @discardableResult
    static func updateTags(
        to tags: some Collection<IGTag>,
        for source: some IGTaggable,
        in context: ModelContext
    ) throws -> Bool {

        let links = try context.tagLinks(for: source)

        return try updateLinks(
            desiredTags: tags,
            existingLinks: links,
            addLink: { tag in IGSourceTagLink(source, tag: tag) },
            in: context
        )
    }

    @discardableResult
    static func updateTags(
        to tags: some Collection<IGTag>,
        for scope: IGTagScope,
        in context: ModelContext
    ) throws -> Bool {

        let links = try context.tagLinks(at: scope)

        return try updateLinks(
            desiredTags: tags,
            existingLinks: links,
            addLink: { tag in IGSourceTagLink(scope: scope, tag: tag) },
            in: context
        )
    }

    @discardableResult
    static func updateTags(
        to tags: some Collection<IGTempTag>,
        for source: some IGTaggable,
        in context: ModelContext
    ) throws -> Bool {

        let links = try context.tagLinks(for: source)

        return try updateLinks(
            desiredTags: tags.map { try $0.getTag(in: context) },
            existingLinks: links,
            addLink: { tag in IGSourceTagLink(source, tag: tag) },
            in: context
        )
    }
 
    @discardableResult
    static func updateTags(
        to tags: some Collection<IGTempTag>,
        for scope: IGTagScope,
        in context: ModelContext
    ) throws -> Bool {

        let links = try context.tagLinks(at: scope)

        return try updateLinks(
            desiredTags: tags.map { try $0.getTag(in: context) },
            existingLinks: links,
            addLink: { tag in IGSourceTagLink(scope: scope, tag: tag) },
            in: context
        )
    }
    
    @discardableResult
    static func updateTags(
        using tempTags: some Collection<IGTempTag>,
        for sources: Set<IGTaggableIdentity>,
        in context: ModelContext
    ) throws -> Bool {

        guard !sources.isEmpty else { return false }

        // STEP 1 — Partition temp tags
        let resolvedTempTags = tempTags.filter { !$0.isPartiallyApplied }
        let partialTempTags  = tempTags.filter {  $0.isPartiallyApplied }

        // Resolve model tags for fully-applied tags once
        let resolvedTags: [IGTag] = try resolvedTempTags.map {
            try $0.getTag(in: context)
        }

        // STEP 2 — Fetch existing links
        let existingLinks = try context.tagLinks(for: sources)

        // STEP 3 — Group links by source
        let linksBySourceID = Dictionary(
            grouping: existingLinks,
            by: \.sourceID
        )

        var didChange = false

        // STEP 4 — Reconcile per source
        for source in sources {
            let links = linksBySourceID[source.id] ?? []
            let existingTags = links.compactMap(\.tag)

            // Preserve partial tags already applied to this source
            let preservedPartialTags = existingTags.filter { existingTag in
                partialTempTags.contains {
                    $0.value == existingTag.value &&
                    $0.scope == existingTag.scope
                }
            }

            let desiredTagsForSource = resolvedTags + preservedPartialTags

            let changed = try updateLinks(
                desiredTags: desiredTagsForSource,
                existingLinks: links,
                addLink: { tag in
                    IGSourceTagLink(sourceScope: source.tagScope, sourceID: source.id, tag: tag)
                },
                in: context
            )

            didChange = didChange || changed
        }

        return didChange
    }

    @discardableResult
    private static func updateLinks(
        desiredTags: some Collection<IGTag>,
        existingLinks: [IGSourceTagLink],
        addLink: (IGTag) -> IGSourceTagLink,
        in context: ModelContext
    ) throws -> Bool {

        // STEP 1 — Compare logical tag sets
        let desiredValues = Set(desiredTags.map(\.value))
        let currentValues = Set(existingLinks.compactMap { $0.tag?.value })

        if desiredValues == currentValues {
            return false
        }

        // STEP 2 — Remove outdated links
        let desiredIDs = Set(desiredTags.map(\.id))
        let currentTags = existingLinks.compactMap(\.tag)

        for link in existingLinks {
            guard let tag = link.tag else {
                context.delete(link)
                continue
            }
            if !desiredIDs.contains(tag.id) {
                context.delete(link)
            }
        }

        // STEP 3 — Add missing links and persist new tags
        for tag in desiredTags {
            context.insert(tag)

            let alreadyLinked = currentTags.contains { $0.id == tag.id }
            if !alreadyLinked {
                let newLink = addLink(tag)
                context.insert(newLink)
                tag.touch()
            }
        }
        return true
    }
    
    
    @discardableResult
    static func cleanOrphanTags(in context: ModelContext) throws -> Int {
        
        let descriptor = FetchDescriptor<IGTag>(
            predicate: #Predicate { $0.links.isEmpty }
        )
        
        let orphans = try context.fetch(descriptor)
        let count = orphans.count
        
        guard count > 0 else { return 0 }

        orphans.forEach(context.delete)

        return count
    }
    
    static func dedupeByPriority<Tag: IGTagRepresentable & IGPrioritizable>(_ tags: any Collection<Tag>) -> Set<Tag> {
        var best: [String: Tag] = [:]   // uniqueString → chosen tag

        for tag in tags {
            let key = tag.value

            if let existing = best[key] {
                if tag.priorityScore > existing.priorityScore {
                    best[key] = tag
                }
            } else {
                best[key] = tag
            }
        }

        return Set(best.values)
    }
    
    static func sortTempTags<Tag: IGTagRepresentable>(_ tags: any Collection<Tag>) -> [Tag] {
        tags.sorted { lhs, rhs in
            
            if lhs.scope != rhs.scope {
                return lhs.scope > rhs.scope
            }
            if lhs.isPreset != rhs.isPreset {
                return lhs.isPreset && !rhs.isPreset
            }
            return lhs.value.localizedCompare(rhs.value) == .orderedAscending
        }
    }
    
    static func associatedPresetTags(
        for phrase: IGPhrase,
        with settings: IGAppSettings
    ) -> Set<IGTag> {

        let phrasePreset = phrase.presetTags

        let groupPreset = phrase.groupLinks
            .compactMap { $0.group?.presetTags }
            .reduce(into: Set<IGTag>()) { $0.formUnion($1) }
        
        let settingTags = settings.presetTags

        return settingTags
                .union(groupPreset)
                .union(phrasePreset)
    }
    
    static func associatedCustomTagsFilter(for phrase: IGPhrase, sortBy: [SortDescriptor<IGSourceTagLink>] = []) -> FetchDescriptor<IGSourceTagLink> {
        var relevantIDs: Set<UUID> = [
            phrase.id,
            IGTagScope.defaults.id
        ]

        let groupIDs = phrase.groupLinks.compactMap(\.group?.id)
        relevantIDs.formUnion(groupIDs)
        
        let predicate = #Predicate<IGSourceTagLink> { link in
            relevantIDs.contains(link.sourceID)
        }
        
        return FetchDescriptor<IGSourceTagLink>(
            predicate: predicate,
            sortBy: sortBy
        )
    }
    
    static func associatedCustomTags(for phrase: IGPhrase, sortBy: [SortDescriptor<IGSourceTagLink>] = [], in context: ModelContext) throws -> [IGTag] {
        
        let descriptor = associatedCustomTagsFilter(for: phrase, sortBy: sortBy)
        let links = try context.fetch(descriptor)
        
        return links.compactMap(\.tag)
    }
}
