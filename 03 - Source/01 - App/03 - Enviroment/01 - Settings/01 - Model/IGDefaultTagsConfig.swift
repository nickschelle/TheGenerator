//
//  IGDefaultTagsConfig.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-11-17.
//

import Foundation

struct IGDefaultTagsConfig: Codable, Equatable {

    var dateModified: Date = .now

    static let userDefaultsKey = "com.theGenerator.config.defaultTags"

    private enum CodingKeys: String, CodingKey {
        case dateModified
    }

    static func load() -> Self {
        guard
            let data = UserDefaults.standard.data(forKey: Self.userDefaultsKey),
            let decoded = try? JSONDecoder().decode(Self.self, from: data)
        else {
            return IGDefaultTagsConfig()
        }
        return decoded
    }

    @discardableResult
    func save() -> Self {
        var copy = self

        let existing = IGDefaultTagsConfig.load()

        if copy.isMeaningfullyDifferent(from: existing) {
            copy.touch()
        }

        if let data = try? JSONEncoder().encode(copy) {
            UserDefaults.standard.set(data, forKey: Self.userDefaultsKey)
        }

        return copy
    }
}

private extension IGDefaultTagsConfig {

    func isMeaningfullyDifferent(from other: IGDefaultTagsConfig) -> Bool {
        return true
    }
}

extension IGDefaultTagsConfig: IGValueDateStampable { }
