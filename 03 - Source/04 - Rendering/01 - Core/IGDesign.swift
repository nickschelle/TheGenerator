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
    
    static var defaultTheme: Theme {
        Theme.defaultTheme
    }
    
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
        drawLayout(of: phrase, with: theme, into: context)
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

/*
 
 



protocol IGDesign {

    associatedtype Theme: IGTheme
    associatedtype Cache: IGDesignCache where Cache.Theme == Theme

    static var baseName: String { get }
    static var designVersion: Int { get }
    static var themes: [Theme] { get }
    static var cache: Cache? { get set }
    static var presetTags: Set<IGTag> { get }
    
    static func theme(rawValue: String) -> Theme?
    static func displayText(for phrase: String) -> String
    static func resolveTheme(id: String) -> Theme?
    static func imageTitle(for record: IGRecord) -> String
    static func imageDescription(for record: IGRecord) -> String
    static func imageFilename(for record: IGRecord) -> String
    
    static func drawLayout(
        phrase: String,
        theme: Theme,
        cache: Cache,
        in context: CGContext
    )
}

// MARK: - Default Implementations

extension IGDesign where Theme: CaseIterable {

    static var themes: [Theme] {
        Array(Theme.allCases)
    }
}

extension IGDesign {
    
    static var defaultTheme: Theme {
        Theme.defaultTheme
    }
    
    static func theme(rawValue: String) -> Theme? {
        Theme(rawValue: rawValue)
    }

    static var id: String {
        "\(baseName.capitalizedInitials)-\(String(format: "%03d", designVersion))"
    }

    static var shortName: String {
        baseName.capitalizedInitials
    }

    static var displayName: String {
        "\(baseName)"
    }

    static var presetTags: Set<IGTag> {
        [IGTag(baseName, scope: .design, isPreset: true)]
    }
    
    static var presetThemeTags: Set<IGTag> {
        return Set(themes.flatMap(\.presetTags))
    }
    
    static func resolveTheme(id: String) -> Theme? {
        Theme.init(rawValue: id)
    }
    
    
    static func draw(
        _ phrase: String,
        at size: CGSize,
        in theme: Theme,
        into context: CGContext
    ) throws {

        let cache = try resolvedCache(size: size, theme: theme)
        context.clear(CGRect(origin: .zero, size: size))
        drawLayout(phrase: phrase, theme: theme, cache: cache, in: context)
    }

    static func draw(from record: IGRecord, into context: CGContext) throws {

        guard let theme = Theme(rawValue: record.rawTheme) else {
            assertionFailure("Invalid theme for record")
            throw IGRenderError.themeResolutionFailed
        }

        try draw(
            record.phraseValue,
            at: record.size,
            in: theme,
            into: context
        )
    }

    static func render(
        _ phrase: String,
        at size: CGSize,
        in theme: Theme
    ) throws -> CGImage {

        let context = try makeContext(size: size)
        try draw(phrase, at: size, in: theme, into: context)

        guard let image = context.makeImage() else {
            throw IGRenderError.imageCreationFailed
        }

        return image
    }

    static func render(from record: IGRecord) throws -> CGImage {

        guard let theme = Theme(rawValue: record.rawTheme) else {
            assertionFailure("Invalid theme for record")
            throw IGRenderError.themeResolutionFailed
        }

        return try render(
            record.phraseValue,
            at: record.size,
            in: theme
        )
    }
    
    private static func resolvedCache(
        size: CGSize,
        theme: Theme
    ) throws -> Cache {

        if cache?.size != size || cache?.theme.id != theme.id {
            cache = Cache(at: size, with: theme)
        }

        guard let cache else {
            throw IGRenderError.cacheInitializationFailed
        }

        return cache
    }
    
    private static func makeContext(size: CGSize) throws -> CGContext {
        guard let ctx = CGContext(
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
        return ctx
    }
}
*/
