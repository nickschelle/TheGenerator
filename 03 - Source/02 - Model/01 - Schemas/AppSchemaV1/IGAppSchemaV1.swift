//
//  IGAppSchemaV1.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-12-01.
//
import Foundation
import SwiftData

enum IGAppSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] {[
        IGPhrase.self,
        IGGroup.self,
        IGGroupPhraseLink.self,
        IGTag.self
    ]}
}
