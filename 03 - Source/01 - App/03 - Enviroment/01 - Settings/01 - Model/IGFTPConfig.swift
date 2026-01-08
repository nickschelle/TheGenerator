//
//  IGFTPConfig.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-10-07.
//

import Foundation
import Security

struct IGFTPConfig: Codable {
    
    var host: String = "ftp.fineartamerica.com"
    var port: Int = 21
    var useTLS: Bool = true
    var username: String = ""
    var remoteBasePath: String = "/Unprocessed"
    var maxConcurrentUploads: Int = 4
    var passwordKeychainID: String = "com.iheart.ftp.default.password"
    var password: String = ""
    var dateModified: Date = .now
    var hasStoredPassword: Bool {
        Self.loadPassword(for: passwordKeychainID) != nil
    }

    static let userDefaultsKey = "com.theGenerator.config.ftp"
    
    private enum CodingKeys: String, CodingKey {
        case host, port, useTLS, username, remoteBasePath, maxConcurrentUploads, passwordKeychainID
    }
    
    static func load() -> Self {
        var config = Self()
        
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode(Self.self, from: data) {
            config = decoded
        }
        
        config.password = loadPassword(for: config.passwordKeychainID) ?? ""
        return config
    }

    @discardableResult
    func save() -> Self {
        var configToSave = self

        let existing: IGFTPConfig? = {
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
            print("⚠️ Failed to encode IHFTPConfig:", error)
        }

        if !password.isEmpty {
            Self.storePassword(password, for: passwordKeychainID)
        } else {
            Self.deletePassword(for: passwordKeychainID)
        }
        return self
    }
    
    func deletePassword() {
        Self.deletePassword(for: passwordKeychainID)
    }
    
    static func deletePassword(for key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}

private extension IGFTPConfig {
    
    static func storePassword(_ password: String, for key: String) {
        let data = Data(password.utf8)
        deletePassword(for: key) // remove any existing entry
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            print("⚠️ Failed to store password for key \(key): \(status)")
        }
    }
    
    static func loadPassword(for key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status == errSecSuccess,
              let data = item as? Data,
              let password = String(data: data, encoding: .utf8)
        else { return nil }
        
        return password
    }
    
    func isMeaningfullyDifferent(from existing: IGFTPConfig) -> Bool {
        if host != existing.host ||
            port != existing.port ||
            useTLS != existing.useTLS ||
            username != existing.username ||
            remoteBasePath != existing.remoteBasePath ||
            maxConcurrentUploads != existing.maxConcurrentUploads ||
            passwordKeychainID != existing.passwordKeychainID {
            return true
        }

        let existingPassword = IGFTPConfig.loadPassword(for: existing.passwordKeychainID) ?? ""
        return password != existingPassword
    }
}

extension IGFTPConfig: IGValueDateStampable { }
