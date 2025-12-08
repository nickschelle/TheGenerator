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
    ) -> Result<Bool, Error> {
        
        let normalized = IHGroup.normalize(rawName)
            
        // MARK: - Uniqueness Check
        let descriptor = FetchDescriptor<IHGroup>(
            predicate: #Predicate { $0.name == normalized }
        )
        
        do {
            guard try context.fetchCount(descriptor) == 0 else {
                return .success(false)
            }
        } catch {
            print("⚠️ Failed to fetch existing group count: \(error)")
            return .failure(error)
        }
        
        // MARK: - Compute next sort order
        let nextSortOrder: Int
        do {
            let count = try context.fetchCount(FetchDescriptor<IHGroup>())
            nextSortOrder = count
        } catch {
            print("⚠️ Failed to count groups: \(error)")
            return .failure(error)
        }
        
        // MARK: - Create new group
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
        
        // MARK: - Save
        do {
            try context.save()
            return .success(true)
        } catch {
            print("⚠️ Failed to save new group: \(error)")
            return .failure(error)
        }
    }
    
    @discardableResult
    static func deleteGroups(
        _ groups: some Collection<IHGroup>,
        in context: ModelContext
    ) -> Result<Void, Error> {
        
        guard !groups.isEmpty else { return .success(()) }
        
        var lowestSortOrder = Int.max
        for group in groups {
            lowestSortOrder = min(lowestSortOrder, group.sortOrder)
            
            // MARK: - Future: Remove Relational Links
            /*
            removeAllPhrases(from: group, in: context)
            removeAllTags(from: group, in: context)
            */
            
            context.delete(group)
        }
        
        // MARK: - Renumber Remaining Groups
        do {
            let descriptor = FetchDescriptor<IHGroup>(
                sortBy: [SortDescriptor(\.sortOrder)]
            )
            
            var remaining = try context.fetch(descriptor)
            if !remaining.isEmpty {
                let startIndex = max(0, lowestSortOrder)
                
                // Ensure startIndex is within bounds
                if startIndex < remaining.count {
                    remaining.renumber(from: startIndex)
                } else {
                    // Sort order gap too large — start from 0
                    remaining.renumber(from: 0)
                }
            }
            
        } catch {
            print("⚠️ Failed to fetch groups for renumbering:", error)
            return .failure(error)
        }
        
        // MARK: - Save Context
        do {
            try context.save()
            return .success(())
        } catch {
            print("⚠️ Failed to save context after deleting groups:", error)
            return .failure(error)
        }
    }
}
