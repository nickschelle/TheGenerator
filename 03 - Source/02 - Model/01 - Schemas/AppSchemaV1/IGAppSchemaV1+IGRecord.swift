//
//  IGAppSchemaV1+IGRecord.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2026-01-02.
//

import Foundation
import SwiftData

extension IGAppSchemaV1 {
    
    @Model
    final class IGRecord {
        
        var id: UUID = UUID()
        
        init() { }
    }
}
