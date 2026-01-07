//
//  IGDesignCache.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-10-31.
//

import Foundation

protocol IGDesignCache: Codable {

    associatedtype Theme: IGTheme

    var size: CGSize { get }
    var theme: Theme { get }

    init(at size: CGSize, with theme: Theme)
}
