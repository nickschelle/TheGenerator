//
//  IGPreviewable.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-09-21.
//

import Foundation
import SwiftData

protocol IGPreviewable: PersistentModel {
    static var previewData: [Self] { get }
}
