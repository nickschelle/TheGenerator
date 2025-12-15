//
//  IGTagActionType.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-09-27.
//

import Foundation
import SwiftUI

enum IGTagActionType: String {
    case add
    case remove
    case delete

    var icon: String {
        switch self {
        case .add:    return "plus"
        case .remove: return "minus"
        case .delete: return "xmark"
        }
    }

    var color: Color {
        switch self {
        case .add:    return .green
        case .remove: return .blue
        case .delete: return .red
        }
    }
    var hint: String {
        switch self {
        case .add:    return "Tap to add"
        case .remove: return "Tap to remove"
        case .delete: return "Tap to delete"
        }
    }

    static func resolve(for tag: IGTempTag, isRemoving: Bool) -> Self {
        if isRemoving {
            if tag.isPartiallyApplied {
                return .add
            }
            return tag.isShared ? .remove : .delete
        } else {
            return .add
        }
    }
}
