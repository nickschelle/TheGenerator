//
//  IGGroupManager.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-12-06.
//

import Foundation
import SwiftData

enum IGGroupManager {
    
    @discardableResult
    static func newGroup(
        _ rawName: String,
        //with tags: Set<IGTempTag> = [],
        in context: ModelContext
    ) throws -> Bool {
        
        let normalized = IGGroup.normalizeForSave(rawName)
            
        let descriptor = FetchDescriptor<IGGroup>(
            predicate: #Predicate { $0.name == normalized }
        )
        guard try context.fetchCount(descriptor) == 0 else { return false }
        
        let nextSortOrder = try context.fetchCount(FetchDescriptor<IGGroup>())
        
        let group = IGGroup(normalized, sortOrder: nextSortOrder)
        context.insert(group)
        
        // MARK: - Apply tags (future)
        /*
        IGTagManager.updateTags(
            to: tags,
            for: group,
            in: context
        )
        */
        return true
    }
    
    static func updateGroup(
        _ group: IGGroup,
        to newName: String,
        //with tags: some Collection<IHTempTag>,
        in context: ModelContext
    ) throws -> Bool {
        var touched = false

        let normalized = IGGroup.normalizeForSave(newName)
        
        // MARK: - Name Update
        if group.name != normalized {
            let descriptor = FetchDescriptor<IGGroup>(
                predicate: #Predicate { $0.name == normalized }
            )
            guard try context.fetchCount(descriptor) == 0 else { return false }
            
            group.name = normalized
            touched = true
        }
        
        /*
        // MARK: - Tag Update
        if IHTagManager.updateTags(to: tags, for: group, in: context) {
            touched = true
        }
         */
        // MARK: - Only touch + save if something changed
        if touched {
            group.touch()
        }
        return true
    }
    
    static func deleteGroups(
        _ groups: some Collection<IGGroup>,
        in context: ModelContext
    ) throws {
        
        guard !groups.isEmpty else { return }
        
        var lowestSortOrder = Int.max
        
        for group in groups {
            lowestSortOrder = min(lowestSortOrder, group.sortOrder)
            
            removeAllPhrases(from: group, in: context)
            //removeAllTags(from: group, in: context)
            
            context.delete(group)
        }
        
        // MARK: - Fetch remaining groups (sorted by existing sortOrder)
        let descriptor = FetchDescriptor<IGGroup>(
            sortBy: [SortDescriptor(\.sortOrder)]
        )
        
        var remaining = try context.fetch(descriptor)
        guard !remaining.isEmpty else { return }
        
        let startIndex = min(max(0, lowestSortOrder), remaining.count - 1)
        
        try remaining.renumber(from: startIndex)
    }
    
    static func add(
        _ phrases: some Collection<IGPhrase>,
        to groups: some Collection<IGGroup>,
        in context: ModelContext
    ) {
        guard !phrases.isEmpty, !groups.isEmpty else { return }
        
        for group in groups {
            
            let existingOrders = group.phraseLinks.map(\.sortOrder)
            var nextOrder = (existingOrders.max() ?? -1) + 1
            
            for phrase in phrases {
                let alreadyLinked = group.phraseLinks.contains {
                    $0.phrase?.id == phrase.id
                }
                if alreadyLinked { continue }
                
                let link = IGGroupPhraseLink(
                    group: group,
                    phrase: phrase,
                    sortOrder: nextOrder
                )
                context.insert(link)
                nextOrder += 1
                phrase.touch()
            }
            
            group.touch()
        }
    }

    static func remove(
        _ phrases: some Collection<IGPhrase>,
        from groups: some Collection<IGGroup>,
        in context: ModelContext
    ) throws {
        
        guard !phrases.isEmpty, !groups.isEmpty else { return }
        
        let phraseIDs = Set(phrases.map(\.id))
        
        for group in groups {
            
            // 1. Identify links to remove
            let linksToRemove = group.phraseLinks.filter {
                guard let pid = $0.phrase?.id else { return false }
                return phraseIDs.contains(pid)
            }
            
            guard !linksToRemove.isEmpty else { continue }
            
            // Track lowest affected sortOrder
            let lowestSortOrder = linksToRemove
                .map(\.sortOrder)
                .min() ?? 0
            
            // 2. Remove from the relationship first (safe + efficient)
            group.phraseLinks.removeAll { link in
                linksToRemove.contains(where: { $0 === link })
            }
            
            // 3. Mark objects for deletion in the context
            for link in linksToRemove {
                context.delete(link)
            }
            
            // 4. Renumber remaining links using the updated relationship array
            var remaining = group.phraseLinks.sorted { $0.sortOrder < $1.sortOrder }
            try remaining.renumber(from: lowestSortOrder)
            
            group.touch()
        }
    }
    
    static func resetGroupsSortOrder(in context: ModelContext) throws {
        let descriptor = FetchDescriptor<IGGroup>(
            sortBy: [SortDescriptor(\.name)]
        )
        var groups = try context.fetch(descriptor)
        guard !groups.isEmpty else { return }
        try groups.renumber()
    }
    
    static func removeAllPhrases(from group: IGGroup, in context: ModelContext) {
        for link in group.phraseLinks {
            context.delete(link)
            link.phrase?.touch()
        }
        group.touch()
    }
}
