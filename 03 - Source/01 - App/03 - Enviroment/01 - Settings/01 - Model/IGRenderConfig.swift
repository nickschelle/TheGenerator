//
//  IGRenderConfig.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2026-01-28.
//

import Foundation

struct IGRenderConfig: Codable {
    var concurrency: IGRenderConcurrency = .automatic
    var customConcurrency: Int? = nil
    
    static let userDefaultsKey = "com.theGenerator.config.render"

    static func load() -> Self {
        let data = MainActor.assumeIsolated {
            UserDefaults.standard.data(forKey: userDefaultsKey)
        }

        guard let data,
              let decoded = try? JSONDecoder().decode(Self.self, from: data)
        else { return Self() }

        return decoded
    }

    @discardableResult
    func save() -> Self {
        do {
            let data = try JSONEncoder().encode(self)
            UserDefaults.standard.set(data, forKey: Self.userDefaultsKey)
        } catch {
            print("⚠️ Failed to encode IHMetadataConfig:", error)
        }
        return self
    }
}
