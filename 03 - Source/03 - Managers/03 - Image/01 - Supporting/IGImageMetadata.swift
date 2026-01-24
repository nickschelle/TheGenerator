//
//  IGImageMetadata.swift
//  IHeartEverything
//
//  Created by Nick Schelle on 2025-11-19.
//

import Foundation

nonisolated
struct IGImageMetadata: Codable, Hashable, Identifiable {

    var title: String
    var detailDescription: String
    var author: String
    var keywords: [String]
    var versionInfo: String
    var id: String {
        "\(title)-\(keywords)"
    }

    init(
        title: String,
        detailDescription: String,
        author: String,
        keywords: [String] = [],
        versionInfo: String
    ) {
        self.title = title
        self.detailDescription = detailDescription
        self.author = author
        self.keywords = keywords
        self.versionInfo = versionInfo
    }
}
