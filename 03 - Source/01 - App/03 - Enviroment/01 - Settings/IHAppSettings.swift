//
//  IGAppSettings.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-11-14.
//

import Foundation

@Observable
final class IGAppSettings {

    // MARK: - Stored Properties (Live Copies)

    /// Live FTP settings (host, credentials, upload path, concurrency, etc.).
    ///
    /// Loaded from persistence at startup.
    var ftp: IGFTPConfig = .load()

    /// Live image generation settings (dimensions, colors, fonts, template, etc.).
    var image: IGImageConfig = .load()

    /// Live security-scoped folder/bookmark settings for the output location.
    var location: IGLocationConfig = .load()

    /// Live metadata settings (author, keyword presets, description builder).
    var metadata: IGMetadataConfig = .load()
    
    var defaultTags: IGDefaultTagsConfig = .load()


    // MARK: - Persistence

    /// Saves FTP settings to persistence and refreshes the live observable value.
    @discardableResult
    func saveFTP() -> IGFTPConfig {
        ftp = ftp.save()
        return ftp
    }

    /// Saves image generation settings and refreshes the observable copy.
    @discardableResult
    func saveImage() -> IGImageConfig {
        image = image.save()
        return image
    }

    /// Saves security-scoped folder settings and refreshes the observable copy.
    @discardableResult
    func saveLocation() -> IGLocationConfig {
        location = location.save()
        return location
    }

    /// Saves metadata settings and refreshes the observable live value.
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
    
    func resetSettings() {
        ftp.deletePassword()
        ftp = IGFTPConfig()
        image = IGImageConfig()
        location = IGLocationConfig()
        metadata = IGMetadataConfig()
        defaultTags = IGDefaultTagsConfig()

        saveFTP()
        saveImage()
        saveLocation()
        saveMetadata()
        saveDefaultTags()
    }
    
    func allPresetTags(excludingTemplateOptions excludeTemplateOptions: Bool = false) -> Set<IGTag> {
        var tags = image.presetTags.union(metadata.presetTags)
        
        if !excludeTemplateOptions {
            tags.formUnion(image.presetTemplateOptionTags)
        }
        
        return tags
    }
    
    var phraseAffectingDateModified: Date {
        max(metadata.dateModified, defaultTags.dateModified)
    }
}
