//
//  IGAppSchemaV1+IGDesignPhraseLink.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2026-01-07.
//

import Foundation
import SwiftData

extension IGAppSchemaV1 {

    @Model
    final class IGPhraseDesignLink {

        var id: UUID = UUID()
        var rawDesignKey: String

        @Relationship(deleteRule: .nullify)
        var phrase: IGPhrase?

        init(_ phrase: IGPhrase, designKey: IGDesignKey) {
            self.rawDesignKey = designKey.rawValue
            self.phrase = phrase
        }
    }
}
