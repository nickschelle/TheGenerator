//
//  IGModelContainerManager.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-12-08.
//

import Foundation
import SwiftData

enum IGModelContainerManager {
    
    static func makeContainer(
        inMemory: Bool = false
    ) -> ModelContainer {
        let schema = Schema(versionedSchema: IGSchema.self)
        let config = ModelConfiguration(isStoredInMemoryOnly: inMemory)
        
        do {
            return try ModelContainer(
                for: schema,
                migrationPlan: IGSchemaMigrationPlan.self,
                configurations: config
            )
            
        } catch {
            fatalError("❌ Failed to load ModelContainer: \(error)")
        }
    }
    
    @discardableResult
    static func eraseAllModels(in context: ModelContext) -> Result<String, Error> {
        Result {
            try context.delete(model: IGGroupPhraseLink.self)
            try context.delete(model: IGSourceTagLink.self)
            try context.delete(model: IGPhrase.self)
            try context.delete(model: IGGroup.self)
            try context.delete(model: IGRecord.self)
            try context.delete(model: IGTag.self)
        
            try context.save()

            return "🧹 Successfully erased all models."
        }
    }
}
