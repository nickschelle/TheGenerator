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

    var identity: IGTaggableIdentity {
        IGTaggableIdentity(id: id, tagScope: Self.tagScope)
    }
}

struct IGTaggableIdentity: Hashable {
    let id: UUID
    let tagScope: IGTagScope
}
