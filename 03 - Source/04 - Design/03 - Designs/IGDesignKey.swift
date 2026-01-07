//
//  IGDesignKey.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-12-27.
//

import Foundation

enum IGDesignKey: String, RawRepresentable, CaseIterable, Codable {
    case iHeartPhrase
    
    static var defaultValue: Self { .iHeartPhrase }
}

extension IGDesignKey {
    var design: any IGDesign.Type {
        switch self {
        case .iHeartPhrase: IHeartPhraseDesignV1.self
        }
    }
    
    var displayName: String { design.displayName }
    var shortName: String { design.shortName }
    var themes: [any IGTheme] { design.themes }
    var presetTags: Set<IGTag> { design.presetTags }
    
    func displayText(_ phrase: String) -> String {
        design.displayText(for: phrase)
    }
}

extension IGDesignKey: Identifiable {
    var id: String { design.id }
}

extension IGDesignKey {
    private var userDefaultsKey: String {
        "com.iheart.config.image.\(rawValue)"
    }

    func loadConfig() -> IGDesignConfig {
        guard
            let data = UserDefaults.standard.data(forKey: userDefaultsKey),
            let decoded = try? JSONDecoder().decode(IGDesignConfig.self, from: data)
        else {
            return IGDesignConfig(for: design)
        }

        return decoded
    }

    @discardableResult
    func saveConfig(_ config: IGDesignConfig) -> IGDesignConfig {
        var configToSave = config
        configToSave.touch()

        do {
            let encoded = try JSONEncoder().encode(configToSave)
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        } catch {
            print("⚠️ Failed to encode IGDesignConfig for \(self):", error)
        }

        return configToSave
    }
}
