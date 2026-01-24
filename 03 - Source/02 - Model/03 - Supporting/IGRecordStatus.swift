//
//  IGRecordStatus.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-11-08.
//

import Foundation

enum IGRecordStatus: String, Codable, Equatable, Sendable, CustomStringConvertible, Comparable {

    case queued
    case drawing
    case saving
    case rendered
    case replacedInFolder
    case uploading
    case uploaded
    case replacedOnline
    case failedRender
    case failedUpload
    
    private var progressIndex: Int {
        switch self {
        case .queued: 0
        case .drawing: 1
        case .saving: 2
        case .failedRender: 3
        case .rendered: 4
        case .uploading: 5
        case .failedUpload: 6
        case .uploaded: 7
        case .replacedInFolder: 8
        case .replacedOnline: 9
        }
    }

    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.progressIndex < rhs.progressIndex
    }

    var isQueued: Bool { self < .rendered }
    var isRendered: Bool { (4..<7).contains(progressIndex) }
    var isUploaded: Bool { self == .uploaded }
    var isRenderedOrUploaded: Bool {
        isRendered || isUploaded
    }
    var isArchived: Bool { self > .uploaded }
    var description: String {
        switch self {
        case .queued: "Queued"
        case .drawing: "Drawing..."
        case .saving: "Saving..."
        case .rendered: "Rendered"
        case .replacedInFolder: "Replaced in Folder"
        case .uploading: "Uploading..."
        case .uploaded: "Uploaded"
        case .replacedOnline: "Replaced Online"
        case .failedRender: "Render Failed"
        case .failedUpload: "Upload Failed"
        }
    }
    
    static let defaultValue: Self = .queued
    
    var symbol: String {
            switch self {
            case .queued: "list.bullet.rectangle"
            case .drawing: "paintbrush"
            case .saving: "square.and.arrow.down"
            case .failedRender: "exclamationmark.triangle"
            case .rendered: "photo.badge.checkmark"
            case .replacedInFolder: "photo.on.rectangle.angled"
            case .uploading: "square.and.arrow.up.badge.clock"
            case .failedUpload: "exclamationmark.triangle"
            case .uploaded: "square.and.arrow.up.badge.clock.fill"
            case .replacedOnline: "trash"
            }
        }
}
