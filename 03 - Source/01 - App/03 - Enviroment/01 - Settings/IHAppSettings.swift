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
    
    var presetTags: Set<IGTag> {
        metadata.presetTags
    }
    
    func resetSettings() {
        ftp.deletePassword()
        ftp = IGFTPConfig()
        workspace = IGWorkspaceConfig()
        location = IGLocationConfig()
        metadata = IGMetadataConfig()
        defaultTags = IGDefaultTagsConfig()

        saveFTP()
        saveWorkspace()
        saveLocation()
        saveMetadata()
        saveDefaultTags()
    }

    var phraseAffectingDateModified: Date {
        max(metadata.dateModified, defaultTags.dateModified)
    }
}
