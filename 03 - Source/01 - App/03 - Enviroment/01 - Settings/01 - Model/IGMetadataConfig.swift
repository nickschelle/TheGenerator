//
//  IGMetadataConfig.swift
//  IHeartEverything
//
//  Created by Nick Schelle on 2025-10-18.
//

import Foundation

struct IGMetadataConfig: Codable, Equatable {

    var author: String = "I ♥︎ Everything"
    var descriptionBlock: String = ""
    var dateModified: Date = .now
    
    static let userDefaultsKey = "com.iheart.config.metadata"

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
        var configToSave = self

        let existing: IGMetadataConfig? = {
            if let data = UserDefaults.standard.data(forKey: Self.userDefaultsKey),
               let decoded = try? JSONDecoder().decode(Self.self, from: data) {
                return decoded
            }
            return nil
        }()

        if let existing = existing, isMeaningfullyDifferent(from: existing) {
            configToSave.touch()
        } else if existing == nil {
            configToSave.touch()
        }

        do {
            let data = try JSONEncoder().encode(configToSave)
            UserDefaults.standard.set(data, forKey: Self.userDefaultsKey)
        } catch {
            print("⚠️ Failed to encode IHMetadataConfig:", error)
        }
        return self
    }
}

private extension IGMetadataConfig {

    func isMeaningfullyDifferent(from other: IGMetadataConfig) -> Bool {
        author != other.author ||
        descriptionBlock != other.descriptionBlock
    }
}


extension IGMetadataConfig: IGValueDateStampable { }

extension IGMetadataConfig: IGTagPresetable {
    var presetTags: Set<IGTag> {
        [IGTag(author, scope: .metadata, isPreset: true)]
    }
}
