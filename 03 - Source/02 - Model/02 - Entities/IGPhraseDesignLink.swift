//
//  IGDesignPhraseLink.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2026-01-07.
//

import Foundation

extension IGPhraseDesignLink {
    var designKey: IGDesignKey {
        get { IGDesignKey(rawValue: rawDesignKey) ?? .defaultValue }
        set { rawDesignKey = newValue.rawValue }
    }
}
