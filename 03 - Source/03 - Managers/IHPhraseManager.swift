//
//  IHPhraseManager.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-12-06.
//

import Foundation
import SwiftData

enum IHPhraseManager {
    
    @discardableResult
    static func newPhrase(
        _ rawValue: String,
        in context: ModelContext
    ) throws -> IHPhrase {
        
        let normalized = IHPhrase.normalize(rawValue)
        
        let descriptor = FetchDescriptor<IHPhrase>(
            predicate: #Predicate { $0.value == normalized }
        )

        if let existing = try context.fetch(descriptor).first {
            return existing
        }

        let phrase = IHPhrase(normalized)
        context.insert(phrase)
        return phrase
    }
    
    static func deletePhrases(
        _ phrases: some Collection<IHPhrase>,
        //with settings: IHAppSettings,
        in context: ModelContext
    ) throws {
        for phrase in phrases {
            // Remove group links
            for link in phrase.groupLinks {
                context.delete(link)
                link.group?.touch()
            }
            /*
            IHRecordManager.deleteRecords(phrase.records, with: settings, in: context)
             */
            /*
            // Remove all tag links
            IHTagManager.updateTags(to: [] as Set<IHTag>, for: phrase, in: context)
             */
            // Delete phrase
            context.delete(phrase)
        }
    }
}
