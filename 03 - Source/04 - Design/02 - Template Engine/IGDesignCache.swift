//
//  IGDesignCache.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-10-31.
//

import Foundation

protocol IGDesignCache {

    associatedtype Role: IGDesignRole
    associatedtype Theme: IGDesignTheme
        where Theme.Role == Role

    var size: CGSize { get }
    var theme: Theme { get }

    init(at size: CGSize, theme: Theme)
}
