//
//  IGLocationConfig.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-10-08.
//

import Foundation

struct IGLocationConfig: Codable {

    var bookmarkData: Data?
    var displayPath: String?
    var dateModified: Date = .now

    static let userDefaultsKey = "com.theGenerator.config.location"
    static let subfolderName = "I Heart Images"

    var resolvedURL: URL? {
        guard let bookmarkData else { return nil }
        var isStale = false
        do {
            let url = try URL(
                resolvingBookmarkData: bookmarkData,
                options: [.withSecurityScope],
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            )
            if isStale {
                print("⚠️ Bookmark is stale — please reselect the folder.")
            }
            return url
        } catch {
            print("❌ Failed to resolve bookmark:", error)
            return nil
        }
    }

    @discardableResult
    func withFolderURL(_ folder: URL) -> Self {
        var copy = self

        guard folder.startAccessingSecurityScopedResource() else {
            print("⚠️ Unable to access security-scoped resource for \(folder.path)")
            return self
        }
        defer { folder.stopAccessingSecurityScopedResource() }

        do {
            let data = try folder.bookmarkData(
                options: [.withSecurityScope],
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
            copy.bookmarkData = data
            copy.displayPath = folder.path
            print("✅ Folder bookmarked successfully: \(folder.path)")
        } catch {
            print("❌ Failed to create bookmark:", error)
        }

        return copy
    }

    func cleared() -> Self {
        var copy = self
        copy.bookmarkData = nil
        copy.displayPath = nil
        return copy
    }
    
    func startAccessing() -> URL? {
        guard let url = resolvedURL else { return nil }
        if url.startAccessingSecurityScopedResource() {
            return url
        } else {
            print("⚠️ Failed to start security scope for:", url)
            return nil
        }
    }

    func stopAccessing() {
        resolvedURL?.stopAccessingSecurityScopedResource()
    }

    static func load() -> Self {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let decoded = try? JSONDecoder().decode(Self.self, from: data)
        else { return Self() }

        // Validate bookmark target
        if let resolved = decoded.resolvedURL {
            guard resolved.startAccessingSecurityScopedResource() else {
                print("⚠️ Unable to access security-scoped resource for \(resolved.path)")
                return Self()
            }
            defer { resolved.stopAccessingSecurityScopedResource() }

            var isDirectory: ObjCBool = false
            if FileManager.default.fileExists(atPath: resolved.path, isDirectory: &isDirectory),
               isDirectory.boolValue {
                return decoded
            } else {
                print("⚠️ Saved folder no longer exists — resetting IHLocationConfig.")
                return Self()
            }
        } else {
            return Self()
        }
    }

    @discardableResult
    func save() -> Self{
        var configToSave = self

        let existing: IGLocationConfig? = {
            if let data = UserDefaults.standard.data(forKey: Self.userDefaultsKey),
               let decoded = try? JSONDecoder().decode(Self.self, from: data) {
                return decoded
            }
            return nil
        }()

        if let existing = existing, configToSave.isMeaningfullyDifferent(from: existing) {
            configToSave.touch()
        } else if existing == nil {
            configToSave.touch()
        }

        do {
            let data = try JSONEncoder().encode(configToSave)
            UserDefaults.standard.set(data, forKey: Self.userDefaultsKey)
        } catch {
            print("⚠️ Failed to encode IHLocationConfig:", error)
        }
        return self
    }
    /*
    static func ensureAvailableOrImport(
        in app: IGAppModel,
        onSuccess: @escaping (URL) -> Void,
        onFailure: @escaping () -> Void
    ) {
        let config = load()
        if let url = config.resolvedURL {
            onSuccess(url)
            return
        }

        app.onLocationImportSuccess = onSuccess
        app.onLocationImportFailure = onFailure
        app.locationImportInProgress = true
    }
     */
}


// MARK: - Private Helpers

private extension IGLocationConfig {

    /// Determines whether the current configuration meaningfully differs
    /// from a previously saved configuration, ignoring transient fields like `dateModified`.
    func isMeaningfullyDifferent(from existing: IGLocationConfig) -> Bool {
        return bookmarkData != existing.bookmarkData ||
               displayPath != existing.displayPath
    }
}


// MARK: - Protocol Conformance

extension IGLocationConfig: IGValueDateStampable { }
