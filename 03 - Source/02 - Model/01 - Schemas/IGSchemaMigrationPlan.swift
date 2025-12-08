//
//  IGSchemaMigrationPlan.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-12-08.
//

import Foundation
import SwiftData

enum IGSchemaMigrationPlan: SchemaMigrationPlan {
    
    static var schemas: [any VersionedSchema.Type] {
        [IGAppSchemaV1.self]
    }
    
    static var stages: [MigrationStage] {
        []
    }
    
}
