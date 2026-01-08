//
//  IGAppSchemaV1+IGGroupDesignLink.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2026-01-07.
//

import Foundation
import SwiftData

extension IGAppSchemaV1 {

    @Model
    final class IGGroupDesignLink {

        var id: UUID = UUID()
        var rawDesignKey: String

        @Relationship(deleteRule: .nullify)
        var group: IGGroup?

        init(_ group: IGGroup, designKey: IGDesignKey) {
            self.rawDesignKey = designKey.rawValue
            self.group = group
        }
    }
}
