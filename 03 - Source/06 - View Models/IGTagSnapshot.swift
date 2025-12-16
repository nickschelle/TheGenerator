//
//  IGTagSnapshot.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-10-18.
//

import Foundation

struct IGTagSnapshot: Codable, Hashable {

    let id: UUID
    let value: String

    let rawScope: String

    var scope: IGTagScope {
        IGTagScope(rawValue: rawScope) ?? .defaultValue
    }

    let isPreset: Bool

    init(from tag: IGTag) {
        self.id = tag.id
        self.value = tag.value
        self.rawScope = tag.rawScope
        self.isPreset = tag.isPreset
    }
}
