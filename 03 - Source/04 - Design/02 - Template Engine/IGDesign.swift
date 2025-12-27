//
//  IGDesign.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2024-07-23.
//

import Cocoa

protocol IGDesign: IGTagPresetable {

    associatedtype Role: IGDesignRole
    associatedtype Theme: IGDesignTheme where Theme.Role == Role
    associatedtype Cache: IGDesignCache where Cache.Role == Role, Cache.Theme == Theme

    static var name: String { get }
    static var version: Int { get }
    static var themes: [Theme] { get }
    static func format(_ phrase: String) -> String
    //static func title(from record: IHRecord) -> String
    //static func description(from record: IHRecord) -> String
    //static func fileName(from record: IHRecord) -> String
    static func drawLayout(
        phrase: String,
        theme: Theme,
        cache: Cache,
        in context: CGContext
    )
    static var cache: Cache? { get set }
}

// MARK: - Default Implementations

extension IGDesign {
    
    static var themes: [Theme] { Array(Theme.allCases) }

    static var id: String {
        "\(name.capitalizedInitials)-\(String(format: "%03d", version))"
    }
    
    static var shortName: String {
        "\(name.capitalizedInitials)"
    }

    static var displayName: String {
        "\(name) Version \(version)"
    }

    static var presetTags: Set<IGTag> {
        [IGTag(name, scope: .template, isPreset: true)]
    }
    
    static var presetOptionTags: Set<IGTag> {
        return Set(themes.flatMap(\.presetTags))
    }

    // MARK: - Record Metadata
/*
    static func title(from record: IHRecord) -> String {
        "\(format(record.phraseValue)) in \(record.color.displayName)"
    }

    static func description(from record: IHRecord) -> String {
        "'\(format(record.phraseValue))' graphic with \(record.color.displayName)"
    }

    static func fileName(from record: IHRecord) -> String {
        [
            record.template.shortName,
            record.phraseValue.pascalCased,
            record.color.displayName
            "\(record.width)x\(record.height)"
        ].joined(separator: "_")
    }
*/
    static func render(
        _ phrase: String,
        at size: CGSize,
        in theme: Theme,
        into externalContext: CGContext? = nil
    ) -> CGImage? {
        if cache?.size != size || cache?.theme.id != theme.id {
            cache = Cache(at: size, theme: theme)
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
