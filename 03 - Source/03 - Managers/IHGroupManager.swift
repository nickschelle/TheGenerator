//
//  IHGroupManager.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-12-06.
//

import Foundation
import SwiftData

enum IHGroupManager {
    
    @discardableResult
    static func newGroup(
        _ rawName: String,
        //with tags: Set<IHTempTag> = [],
        in context: ModelContext
    ) throws -> Bool {
        
        let normalized = IHGroup.normalize(rawName)
            
        let descriptor = FetchDescriptor<IHGroup>(
            predicate: #Predicate { $0.name == normalized }
        )
        guard try context.fetchCount(descriptor) == 0 else { return false }
        
        let nextSortOrder = try context.fetchCount(FetchDescriptor<IHGroup>())
        
        let group = IHGroup(normalized, sortOrder: nextSortOrder)
        context.insert(group)
        
        // MARK: - Apply tags (future)
        /*
        IHTagManager.updateTags(
            to: tags,
            for: group,
            in: context
        )
        */
        return true
    }
    
    static func deleteGroups(
        _ groups: some Collection<IHGroup>,
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
        let descriptor = FetchDescriptor<IHGroup>(
            sortBy: [SortDescriptor(\.sortOrder)]
        )
        
        var remaining = try context.fetch(descriptor)
        guard !remaining.isEmpty else { return }
        
        let startIndex = min(max(0, lowestSortOrder), remaining.count - 1)
        
        try remaining.renumber(from: startIndex)
    }
    
    static func add(
        _ phrases: some Collection<IHPhrase>,
        to groups: some Collection<IHGroup>,
        in context: ModelContext
    ) {
        guard !phrases.isEmpty, !groups.isEmpty else { return }
        
        for group in groups {
            
            // Compute next sequential sortOrder safely
            let existingOrders = group.phraseLinks.map(\.sortOrder)
            var nextOrder = (existingOrders.max() ?? -1) + 1
            
            for phrase in phrases {
                // Skip if the link already exists
                let alreadyLinked = group.phraseLinks.contains {
                    $0.phrase?.id == phrase.id
                }
                if alreadyLinked { continue }
                
                let link = IHGroupPhraseLink(
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

    // MARK: - Remove Phrases from Groups

    /// Removes a set of phrases from a set of groups.
    static func remove(
        _ phrases: some Collection<IHPhrase>,
        from groups: some Collection<IHGroup>,
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
        let descriptor = FetchDescriptor<IHGroup>(
            sortBy: [SortDescriptor(\.name)]
        )
        var groups = try context.fetch(descriptor)
        guard !groups.isEmpty else { return }
        try groups.renumber()
    }
    
    static func removeAllPhrases(from group: IHGroup, in context: ModelContext) {
        for link in group.phraseLinks {
            context.delete(link)
            link.phrase?.touch()
        }
        group.touch()
    }
}
