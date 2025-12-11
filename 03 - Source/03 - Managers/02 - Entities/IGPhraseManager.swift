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
        tags: (any Collection<IGTag>)? = nil,
        in context: ModelContext
    ) throws -> Bool {

        var didChange = false

        if let value, !value.isEmpty {
            let normalized = IGPhrase.normalizeForSave(value)

            if normalized != phrase.value, !normalized.isEmpty {
                let descriptor = FetchDescriptor<IGPhrase>(
                    predicate: #Predicate { $0.value == normalized }
                )

                if try context.fetchCount(descriptor) > 0 {
                    return false
                }
                
                phrase.value = normalized
                didChange = true
            }
        }

        if let tags, try IGTagManager.updateTags(to: tags, for: phrase, in: context) {
            didChange = true
        }

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
            for link in phrase.groupLinks {
                context.delete(link)
                link.group?.touch()
            }
            /*
            IGRecordManager.deleteRecords(phrase.records, with: settings, in: context)
             */

            try IGTagManager.updateTags(to: Set<IGTag>(), for: phrase, in: context)

            context.delete(phrase)
        }
    }
}
