//
//  IGDesign.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2024-07-23.
//

import Cocoa

protocol IGDesign {

    associatedtype Theme: IGDesignTheme

    static var baseName: String { get }
    static var designVersion: Int { get }
    static var defaultTheme: Theme { get }
    
    @MainActor static var presetTags: Set<IGTag> { get }

    static func theme(rawValue: String) throws -> Theme
    static func displayText(for phrase: String) -> String

    static func drawLayout(
        of phrase: String,
        at size: CGSize,
        with theme: Theme,
        into context: CGContext
    )
}

extension IGDesign where Theme: CaseIterable {

    static var themes: [Theme] {
        Array(Theme.allCases)
    }
}

extension IGDesign {
    static var id: String {
        "\(baseName.capitalizedInitials)-\(String(format: "%03d", designVersion))"
    }
    
    static var shortName: String {
        baseName.capitalizedInitials
    }

    static var displayName: String {
        "\(baseName)"
    }
    
    static func theme(rawValue: String) throws -> Theme {
        guard let theme = Theme(rawValue: rawValue) else {
            throw IGRenderError.themeResolutionFailed
        }
        return theme
    }
    
    static func drawImage(
        of phrase: String,
        at size: CGSize,
        with theme: Theme,
        into context: CGContext
    ) {
        context.clear(CGRect(origin: .zero, size: size))
        drawLayout(of: phrase, at: size, with: theme, into: context)
    }
    
    static func renderImage(
        of phrase: String,
        at size: CGSize,
        with rawTheme: String
    ) throws -> CGImage {

        let theme = try theme(rawValue: rawTheme)
        let context = try makeContext(size: size)

        drawImage(
            of: phrase,
            at: size,
            with: theme,
            into: context
        )

        guard let image = context.makeImage() else {
            throw IGRenderError.imageCreationFailed
        }

        return image
    }
    
    private static func makeContext(size: CGSize) throws -> CGContext {
        guard let context = CGContext(
            data: nil,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            throw IGRenderError.contextCreationFailed
        }
        return context
    }
}
