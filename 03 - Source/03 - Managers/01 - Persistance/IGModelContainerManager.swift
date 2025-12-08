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
}
