//
//  IGDesign.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2024-07-23.
//

import Cocoa

protocol IGDesign {

    associatedtype Theme: IGTheme
    associatedtype Cache: IGDesignCache where Cache.Theme == Theme

    static var baseName: String { get }
    static var designVersion: Int { get }
    static var themes: [Theme] { get }
    static var cache: Cache? { get set }
    static var presetTags: Set<IGTag> { get }
    
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
    
    static func imageTitle(for record: IGRecord) -> String {
        "\(displayText(for: record.phraseValue)) in \(record.theme.displayName)"
    }
    
    static func imageDescription(for record: IGRecord) -> String {
        "'\(displayText(for: record.phraseValue))' graphic in \(record.theme.displayName) theme."
    }
    static func imageFilename(for record: IGRecord) -> String {
        [
            record.design.shortName,
            record.phraseValue.pascalCased,
            record.theme.displayName,
            "\(record.width)x\(record.height)"
        ].joined(separator: "_")
    }

    static func render(
        _ phrase: String,
        at size: CGSize,
        in theme: Theme,
        into externalContext: CGContext? = nil
    ) -> CGImage? {
        if cache?.size != size || cache?.theme.id != theme.id {
            cache = Cache(at: size, with: theme)
        }

        guard let cache else {
            assertionFailure("Cache should have been initialized via `Cache(at:in:)`.")
            return nil
        }

        let context: CGContext = externalContext ?? {
            guard let ctx = CGContext(
                data: nil,
                width: Int(size.width),
                height: Int(size.height),
                bitsPerComponent: 8,
                bytesPerRow: 0,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            ) else {
                print("❌ Failed to create CGContext")
                return nil
            }
            ctx.clear(CGRect(origin: .zero, size: size))
            return ctx
        }()!

        let ownsContext = (externalContext == nil)

        drawLayout(phrase: phrase, theme: theme, cache: cache, in: context)

        return ownsContext ? context.makeImage() : nil
    }
    /*
    /// Convenience overload for rendering directly from a record.
    static func render(from record: IHRecord, into externalContext: CGContext? = nil) -> CGImage? {
        render(
            record.phraseValue,
            at: record.size,
            in: record.color,
            font: record.font,
            into: externalContext
        )
    }
     */
}
