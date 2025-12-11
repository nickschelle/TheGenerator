//
//  IGSourceTagLink.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-12-10.
//

import Foundation

extension IGSourceTagLink {
    
    convenience init(_ source: some IGTaggable, tag: IGTag) {
        self.init(
            sourceScope: type(of: source).tagScope,
            sourceID: source.id,
            tag: tag
        )
    }

    convenience init(scope: IGTagScope, tag: IGTag) {
        self.init(
            sourceScope: scope,
            sourceID: scope.id,
            tag: tag
        )
    }

    var sourceScope: IGTagScope {
        get { IGTagScope(rawValue: rawSourceScope) ?? .defaultValue }
        set { rawSourceScope = newValue.rawValue }
    }
}
