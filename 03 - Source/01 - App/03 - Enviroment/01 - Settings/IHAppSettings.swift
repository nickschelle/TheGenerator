//
//  IGAppSettings.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-11-14.
//

import Foundation

@Observable
final class IGAppSettings {

    // MARK: - Stored Properties (Live Copies).
    var ftp: IGFTPConfig = .load()
    var workspace: IGWorkspaceConfig = .load()
    var location: IGLocationConfig = .load()
    var metadata: IGMetadataConfig = .load()
    var defaultTags: IGDefaultTagsConfig = .load()
    var render: IGRenderConfig = .load()
    var designConfigs: [IGDesignKey: IGDesignConfig] = [:]

    
    init() {
        self.ftp = IGFTPConfig.load()
        self.workspace = IGWorkspaceConfig.load()
        self.location = IGLocationConfig.load()
        self.metadata = IGMetadataConfig.load()
        self.defaultTags = IGDefaultTagsConfig.load()
        self.render = IGRenderConfig.load()
        IGDesignKey.allCases.forEach { key in
            designConfigs[key] = key.loadConfig()
        }
    }

    // MARK: - Persistence
    @discardableResult
    func saveFTP() -> IGFTPConfig {
        ftp = ftp.save()
        return ftp
    }

    @discardableResult
    func saveWorkspace() -> IGWorkspaceConfig {
        workspace = workspace.save()
        return workspace
    }

    @discardableResult
    func saveLocation() -> IGLocationConfig {
        location = location.save()
        return location
    }

    @discardableResult
    func saveMetadata() -> IGMetadataConfig {
        metadata = metadata.save()
        return metadata
    }
    
    func touchDefaultTags() {
        defaultTags.touch()
    }
    
    @discardableResult
    func saveDefaultTags() -> IGDefaultTagsConfig {
        defaultTags = defaultTags.save()
        return defaultTags
    }
    
    @discardableResult
    func saveRender() -> IGRenderConfig {
        render = render.save()
        return render
    }
    
    func designConfig(for key: IGDesignKey) -> IGDesignConfig {
        designConfigs[key] ?? IGDesignConfig(for: key.design)
    }

    func saveDesign(_ config: IGDesignConfig, for key: IGDesignKey) {
        designConfigs[key] = config
        key.saveConfig(config)
    }
    
    var presetTags: Set<IGTag> {
        metadata.presetTags.union(workspace.workspace.designKey?.presetTags() ?? [])
    }
    
    func resetSettings() {
        ftp.deletePassword()
        ftp = IGFTPConfig()
        workspace = IGWorkspaceConfig()
        location = IGLocationConfig()
        metadata = IGMetadataConfig()
        defaultTags = IGDefaultTagsConfig()
        render = IGRenderConfig()

        saveFTP()
        saveWorkspace()
        saveLocation()
        saveMetadata()
        saveDefaultTags()
        saveRender()
    }

    var phraseAffectingDateModified: Date {
        max(metadata.dateModified, defaultTags.dateModified)
    }
}
