//
//  IGAppInfo.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-11-18.
//

import Foundation

struct IGAppInfo: Sendable, Codable, Hashable {

    let name: String
    let version: String
    let build: String

    var fullVersion: String {
        "\(version) (\(build))"
    }

    var nameAndVersion: String {
        "\(name): \(fullVersion)"
    }

    init(name: String, version: String, build: String) {
        self.name = name
        self.version = version
        self.build = build
    }
    
    static let defaultValue: IGAppInfo = IGAppInfo(name: "Undefined", version: "", build: "")
}

enum IGAppInfoSnapshot {
    
    @MainActor
    static func current() -> IGAppInfo {
        let bundle = Bundle.main

        let name =
            (bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String) ??
            (bundle.object(forInfoDictionaryKey: "CFBundleName") as? String) ??
            "Unknown App"

        let version = bundle.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0"
        let build = bundle.infoDictionary?["CFBundleVersion"] as? String ?? "0"

        return IGAppInfo(name: name, version: version, build: build)
    }
}
