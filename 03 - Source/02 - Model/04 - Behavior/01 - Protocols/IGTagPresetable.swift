//
//  IGTagPresetable.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-11-10.
//

import SwiftData

protocol IGTagPresetable {
    
    var presetTags: Set<IGTag> { get }
}

extension IGTagPresetable {
    
    var presetTags: Set<IGTag> { [] }
}
