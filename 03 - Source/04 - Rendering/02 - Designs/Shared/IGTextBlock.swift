//
//  IGTextBlock.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-10-31.
//

import Cocoa
import CoreGraphics
import CoreText

struct IGTextBlock {
    
    var text: String
    var fontName: String
    var pointSize: CGFloat
    var color: IGColor
    
    private var ctFont: CTFont {
        CTFontCreateWithName(fontName as CFString, pointSize, nil)
    }

    private var line: CTLine {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: ctFont,
            .foregroundColor: color.cgColor
        ]
        let attributed = NSAttributedString(string: text, attributes: attributes)
        return CTLineCreateWithAttributedString(attributed)
    }

    var width: CGFloat {
        CGFloat(CTLineGetTypographicBounds(line, nil, nil, nil))
    }

    var height: CGFloat {
        CTFontGetAscent(ctFont) + CTFontGetDescent(ctFont) + CTFontGetLeading(ctFont)
    }

    var capHeight: CGFloat {
        CTFontGetCapHeight(ctFont)
    }

    var boundingBoxHeight: CGFloat {
        text.utf16.reduce(0) { maxHeight, char in
            var glyph: CGGlyph = 0
            var input = char
            guard CTFontGetGlyphsForCharacters(ctFont, &input, &glyph, 1) else { return maxHeight }
            var bounds = CGRect.zero
            CTFontGetBoundingRectsForGlyphs(ctFont, .default, &glyph, &bounds, 1)
            return max(maxHeight, bounds.height)
        }
    }

    mutating func scaleToMatchGlyphHeight(_ targetHeight: CGFloat, baseSize: CGFloat = 32) {
        let baseFont = CTFontCreateWithName(fontName as CFString, baseSize, nil)
        var glyph: CGGlyph = 0
        var chars = Array(text.utf16)
        CTFontGetGlyphsForCharacters(baseFont, &chars, &glyph, 1)
        var bounds = CGRect.zero
        CTFontGetBoundingRectsForGlyphs(baseFont, .default, &glyph, &bounds, 1)
        pointSize = (targetHeight * baseSize) / bounds.height
    }

    mutating func scaleToMatchCapHeight(_ targetHeight: CGFloat, baseSize: CGFloat = 32) {
        let baseFont = CTFontCreateWithName(fontName as CFString, baseSize, nil)
        let capHeight = CTFontGetCapHeight(baseFont)
        pointSize = (targetHeight * baseSize) / capHeight
    }

    mutating func scaleToFit(width targetWidth: CGFloat) {
        let scale = targetWidth / width
        pointSize *= scale
    }

    func draw(at position: CGPoint, in context: CGContext) {
        context.saveGState()
        context.textMatrix = .identity
        context.textPosition = position
        CTLineDraw(line, context)
        context.restoreGState()
    }
}
