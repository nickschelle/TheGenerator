//
//  IGTagRepresentable.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-12-10.
//

import Foundation

protocol IGTagRepresentable: IGPresetable, IGTagScopable {
    var value: String { get set }
}
