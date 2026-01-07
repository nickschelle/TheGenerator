//
//  IGWorkspaceConfig.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2026-01-05.
//

import Foundation

struct IGWorkspaceConfig: Codable {

    enum Workspace: Codable, Equatable, Hashable {
        case library
        case design(IGDesignKey)
    }

    // MARK: - Stored Properties

    var workspace: Workspace = .library

    // MARK: - Persistence

    static let userDefaultsKey = "com.iheart.config.workspace"

    static func load() -> Self {
        guard
            let data = UserDefaults.standard.data(forKey: userDefaultsKey),
            let decoded = try? JSONDecoder().decode(Self.self, from: data)
        else {
            return Self()
        }

        return decoded
    }

    @discardableResult
    func save() -> Self {
        do {
            let encoded = try JSONEncoder().encode(self)
            UserDefaults.standard.set(encoded, forKey: Self.userDefaultsKey)
        } catch {
            print("⚠️ Failed to encode IGWorkspaceConfig:", error)
        }

        return self
    }
}

// MARK: - Convenience Accessors

extension IGWorkspaceConfig.Workspace {

    var isLibrary: Bool {
        if case .library = self { return true }
        return false
    }

    var designKey: IGDesignKey? {
        if case let .design(key) = self { return key }
        return nil
    }
}
