//
//  IGPhraseManager.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-12-06.
//

import Foundation
import SwiftData

enum IGPhraseManager {
    
    @discardableResult
    static func newPhrase(
        _ rawValue: String,
        in context: ModelContext
    ) throws -> IGPhrase {
        
        let normalized = IGPhrase.normalizeForSave(rawValue)
        
        let descriptor = FetchDescriptor<IGPhrase>(
            predicate: #Predicate { $0.value == normalized }
        )

        if let existing = try context.fetch(descriptor).first {
            return existing
        }

        let phrase = IGPhrase(normalized)
        context.insert(phrase)
        return phrase
    }
    
    @discardableResult
    static func updatePhrase(
        _ phrase: IGPhrase,
        value: String? = nil,
        // tags: (any Collection<IHTag>)? = nil,
        in context: ModelContext
    ) throws -> Bool {

        var didChange = false

        // 1. Update name if needed
        if let value, !value.isEmpty {
            let normalized = IGPhrase.normalizeForSave(value)

            if normalized != phrase.value, !normalized.isEmpty {
                let descriptor = FetchDescriptor<IGPhrase>(
                    predicate: #Predicate { $0.value == normalized }
                )

                if let existing = try context.fetch(descriptor).first {
                    return false
                }
                
                phrase.value = normalized
                didChange = true
            }
        }
        /*
        // 2. Update tags
        if let tags, IHTagManager.updateTags(to: tags, for: phrase, in: context) {
            didChange = true
        }
         */
        // 3. Persist + touch
        if didChange {
            phrase.touch()
        }

        return true
    }
    
    static func deletePhrases(
        _ phrases: some Collection<IGPhrase>,
        //with settings: IGAppSettings,
        in context: ModelContext
    ) throws {
        for phrase in phrases {
            // Remove group links
            for link in phrase.groupLinks {
                context.delete(link)
                link.group?.touch()
            }
            /*
            IGRecordManager.deleteRecords(phrase.records, with: settings, in: context)
             */
            /*
            // Remove all tag links
            IGTagManager.updateTags(to: [] as Set<IGTag>, for: phrase, in: context)
             */
            // Delete phrase
            context.delete(phrase)
        }
    }
}
