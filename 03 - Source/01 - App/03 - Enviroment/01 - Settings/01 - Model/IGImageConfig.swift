//
//  IGImageConfig.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-10-07.
//

import Foundation

struct IGImageConfig: Codable, Sendable, Equatable {

    //var template: IGTemplateKey = .iHeartV1
    //var fonts: [IHFont] = [.helveticaBold]
    //var colors: Set<IHColor> = [.black, .white]
    var width: Int = 4500
    var height: Int = 4500
    var dateModified: Date = .now

    static let userDefaultsKey = "com.iheart.config.image"

    static func load() -> Self {
        let data = MainActor.assumeIsolated {
            UserDefaults.standard.data(forKey: userDefaultsKey)
        }

        guard let data,
              let decoded = try? JSONDecoder().decode(Self.self, from: data)
        else {
            return Self()
        }

        return decoded
    }

    @discardableResult
    func save() -> Self {
        var configToSave = self

        let existing: IGImageConfig? = {
            guard
                let data = UserDefaults.standard.data(forKey: Self.userDefaultsKey),
                let decoded = try? JSONDecoder().decode(Self.self, from: data)
            else { return nil }
            return decoded
        }()

        if let existing, configToSave.isMeaningfullyDifferent(from: existing) {
            configToSave.touch()
        } else if existing == nil {
            configToSave.touch()
        }

        do {
            let encoded = try JSONEncoder().encode(configToSave)
            UserDefaults.standard.set(encoded, forKey: Self.userDefaultsKey)
        } catch {
            print("⚠️ Failed to encode IHImageConfig:", error)
        }

        return self
    }
    /*
    var recordKeys: Set<IHRecordKey> {
        var keys: Set<IHRecordKey> = []
        keys.reserveCapacity(colors.count * fonts.count)

        for color in colors {
            for font in fonts {
                keys.insert(
                    IHRecordKey(template: template, color: color, font: font)
                )
            }
        }

        return keys
    }
     */
}

private extension IGImageConfig {

    func isMeaningfullyDifferent(from existing: IGImageConfig) -> Bool {
      //  template != existing.template ||
      //  fonts    != existing.fonts    ||
      //  colors   != existing.colors   ||
        width    != existing.width    ||
        height   != existing.height
    }
}

extension IGImageConfig: IGValueDateStampable { }

extension IGImageConfig: IGTagPresetable {

    var presetTags: Set<IGTag> {
       // let templateTags = template.presetTags

        let sizeTag: Set<IGTag> = [
            IGTag("\(width)x\(height)", scope: .size, isPreset: true)
        ]

        return sizeTag // templateTags.union(sizeTag)
    }

    var presetTemplateOptionTags: Set<IGTag> {
        [] //template.presetOptionTags
    }
}
