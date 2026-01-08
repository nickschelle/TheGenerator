//
//  IGDesignKey.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-12-27.
//

import Foundation
import SwiftData

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
        "com.theGenerator.config.image.\(rawValue)"
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
    
    static func connect(
        _ groups: [IGGroup],
        to keys: [IGDesignKey],
        in context: ModelContext
    ) {
        guard !groups.isEmpty, !keys.isEmpty else { return }
        
        for group in groups {
            
            for key in keys {
                let alreadyLinked = group.designLinks.contains {
                    $0.designKey == key
                }
                if alreadyLinked { continue }
                
                let link = IGGroupDesignLink(
                    group,
                    designKey: key
                )
                context.insert(link)
            }
            
            group.touch()
        }
    }
    
    func connect(
        _ groups: [IGGroup],
        in context: ModelContext
    ) {
        IGDesignKey.connect(groups, to: [self], in: context)
    }
    
    static func disconnect(
        _ groups: some Collection<IGGroup>,
        from keys: some Collection<IGDesignKey>,
        in context: ModelContext
    ) {
        guard !groups.isEmpty, !keys.isEmpty else { return }

        let keySet = Set(keys)

        for group in groups {
            let linksToRemove = group.designLinks.filter {
                keySet.contains($0.designKey)
            }

            guard !linksToRemove.isEmpty else { continue }

            for link in linksToRemove {
                context.delete(link)
            }

            group.touch()
        }
    }
    
    func disconnect(
        _ groups: [IGGroup],
        in context: ModelContext
    ) {
        IGDesignKey.disconnect(groups, from: [self], in: context)
    }
    
    static func connect(
        _ phrases: [IGPhrase],
        to keys: [IGDesignKey],
        in context: ModelContext
    ) {
        guard !phrases.isEmpty, !keys.isEmpty else { return }
        
        for phrase in phrases {
            
            for key in keys {
                let alreadyLinked = phrase.designLinks.contains {
                    $0.designKey == key
                }
                if alreadyLinked { continue }
                
                let link = IGPhraseDesignLink(
                    phrase,
                    designKey: key
                )
                context.insert(link)
            }
            
            phrase.touch()
        }
    }
    
    func connect(
        _ phrases: [IGPhrase],
        in context: ModelContext
    ) {
        IGDesignKey.connect(phrases, to: [self], in: context)
    }
    
    static func disconnect(
        _ phrases: some Collection<IGPhrase>,
        from keys: some Collection<IGDesignKey>,
        in context: ModelContext
    ) {
        guard !phrases.isEmpty, !keys.isEmpty else { return }

        let keySet = Set(keys)

        for phrase in phrases {
            let linksToRemove = phrase.designLinks.filter {
                keySet.contains($0.designKey)
            }

            guard !linksToRemove.isEmpty else { continue }

            for link in linksToRemove {
                context.delete(link)
            }

            phrase.touch()
        }
    }
    
    func disconnect(
        _ phrases: [IGPhrase],
        in context: ModelContext
    ) {
        IGDesignKey.disconnect(phrases, from: [self], in: context)
    }
}
