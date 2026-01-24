//
//  CGImage+SavePNG.swift
//  IHeartEverything
//
//  Created by Nick Schelle on 2025-10-29.
//

import Cocoa
import CoreGraphics
import UniformTypeIdentifiers

extension CGImage {

    func savePNG(to url: URL, metadata: IGImageMetadata) throws {

        guard let destination = CGImageDestinationCreateWithURL(
            url as CFURL,
            UTType.png.identifier as CFString,
            1,
            nil
        ) else {
            throw NSError(
                domain: "IHImageSave",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Could not create PNG destination"]
            )
        }

        let keywordCFStrings = metadata.keywords.map { $0 as CFString }

        let imageProperties: [CFString: Any] = [
            kCGImagePropertyPNGDictionary: [
                kCGImagePropertyPNGTitle: metadata.title,
                kCGImagePropertyPNGAuthor: metadata.author,
                kCGImagePropertyPNGDescription: metadata.detailDescription,
                kCGImagePropertyPNGSoftware: metadata.versionInfo 
            ],
            kCGImagePropertyIPTCDictionary: [
                kCGImagePropertyIPTCKeywords: keywordCFStrings
            ]
        ]

        CGImageDestinationAddImage(destination, self, imageProperties as CFDictionary)

        guard CGImageDestinationFinalize(destination) else {
            throw NSError(
                domain: "IHImageSave",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "Failed to finalize PNG write"]
            )
        }
    }
}
