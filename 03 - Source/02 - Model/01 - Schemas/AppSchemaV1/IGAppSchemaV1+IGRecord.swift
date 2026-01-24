//
//  IGAppSchemaV1+IGRecord.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2026-01-02.
//

import Foundation
import SwiftData

extension IGAppSchemaV1 {
    
    @Model
    final class IGRecord {
        
        var id: UUID = UUID()
        var phraseValue: String = "Undefined"
        var author: String = "Undefined"
        var rawDesign: String = IGDesignKey.defaultValue.rawValue
        var rawTheme: String = IGDesignKey.defaultValue.design.defaultTheme.rawValue
        var width: Int = 0
        var height: Int = 0
        var tagSnapshots: [IGTagSnapshot] = []
        var revision: Int = 0
        var rawAppName: String = IGAppInfo.defaultValue.name
        var rawAppVersion: String = IGAppInfo.defaultValue.version
        var rawAppBuild: String = IGAppInfo.defaultValue.build
        var rawStatus: String = IGRecordStatus.defaultValue.rawValue
        
        var failedMessage: String? = nil
        var dateCreated: Date = Date.now

        var dateRendered: Date? = nil
        var renderDuration: TimeInterval? = nil

        var dateUploaded: Date? = nil
        var uploadDuration: TimeInterval? = nil
        
        @Relationship(deleteRule: .nullify)
        var phrase: IGPhrase?
        
        init(
            phrase: IGPhrase? = nil,
            author: String = "Undefined",
            tags: any Collection<IGTag> = [],
            design: IGDesignKey = .defaultValue,
            theme: any IGDesignTheme = IGDesignKey.defaultValue.design.defaultTheme,
            width: Int = 0,
            height: Int = 0,
            id: UUID = UUID(),
            revision: Int = 0,
            appInfo: IGAppInfo = .defaultValue,
            status: IGRecordStatus = .defaultValue,
            failedMessage: String? = nil,
            dateCreated: Date = .now,
            dateRendered: Date? = nil,
            renderDuration: TimeInterval? = nil,
            dateUploaded: Date? = nil,
            uploadDuration: TimeInterval? = nil
        ) {
            self.id = id
            self.phrase = phrase
            self.phraseValue = phrase?.value ?? "Undefined"
            self.author = author
            self.rawDesign = design.rawValue
            self.rawTheme = theme.rawValue
            self.width = width
            self.height = height
            self.revision = revision
            self.rawAppName = appInfo.name
            self.rawAppVersion = appInfo.version
            self.rawAppBuild = appInfo.build
            self.rawStatus = status.rawValue
            self.failedMessage = failedMessage
            self.dateCreated = dateCreated
            self.dateRendered = dateRendered
            self.renderDuration = renderDuration
            self.dateUploaded = dateUploaded
            self.uploadDuration = uploadDuration
            self.tagSnapshots = tags.map { IGTagSnapshot(from: $0) }
        }
    }
}
