//
//  IGPrioritizable.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-12-10.
//

import Foundation

protocol IGPrioritizable {
    var priorityScore: Int { get }
}

extension IGPrioritizable where Self: IGTagScopable & IGPresetable {
    var priorityScore: Int {
        var score = 0

        if !self.isPreset { score += 10 }
        score += self.scope.precedence * 100

        return score
    }
}
