//
//  IGFTPUploadState.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-11-02.
//

import Foundation

enum IGImageUploadState: Codable, Equatable, Sendable {

    case idle
    case uploading
    case complete
    case cancelled
    case failed

    var isBusy: Bool {
        self == .uploading
    }
}
