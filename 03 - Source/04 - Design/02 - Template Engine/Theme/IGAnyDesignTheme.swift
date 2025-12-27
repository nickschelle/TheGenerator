//
//  IGAnyDesignTheme.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-12-26.
//

import Foundation

protocol IGAnyDesignTheme<Role>: IGDesignTheme
where Self.Role == Role {}
