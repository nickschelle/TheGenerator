//
//  IGTaggable.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-09-22.
//

import Foundation
import SwiftData

protocol IGTaggable: PersistentModel {
    var id: UUID { get }
    static var tagScope: IGTagScope { get }
}


extension IGTaggable {

    func hasTag(_ tag: IGTag) -> Bool {
        tag.links.contains {
            $0.sourceID == id &&
            $0.sourceScope == Self.tagScope
        }
    }
}
