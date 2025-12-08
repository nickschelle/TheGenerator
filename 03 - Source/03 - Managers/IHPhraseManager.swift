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
    ) -> Result<IHPhrase, Error> {
        
        let normalized = IHPhrase.normalize(rawValue)
        
        let descriptor = FetchDescriptor<IHPhrase>(
            predicate: #Predicate { $0.value == normalized }
        )
        
        // 1. Try fetching
        do {
            if let existing = try context.fetch(descriptor).first {
                return .success(existing)
            }
        } catch {
            print("⚠️ Failed to fetch existing phrase: \(error)")
            return .failure(error)
        }
        
        // 2. Create new phrase
        let phrase = IHPhrase(normalized)
        context.insert(phrase)
        
        // 3. Save
        do {
            try context.save()
            return .success(phrase)
        } catch {
            print("⚠️ Failed to save new phrase: \(error)")
            return .failure(error)
        }
    }
    
    static func deletePhrases(
        _ phrases: some Collection<IHPhrase>,
        //with settings: IHAppSettings,
        in context: ModelContext
    ) {
        for phrase in phrases {
            /*
            // Remove group links
            for link in phrase.groupLinks {
                context.delete(link)
                link.group?.touch()
            }
            */
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

        do {
            try context.save()
        } catch {
            print("⚠️ Failed to save context after deleting Phrase(s): \(error)")
        }
    }
}
