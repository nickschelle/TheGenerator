//
//  IHeartPhraseDesign.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-12-27.
//

import Foundation
import Cocoa

enum IHeartPhraseDesignV1: IGDesign {
 
    typealias Theme = IHeartPhraseTheme
    
    static let baseName: String = "I ♥ Phrase"
    static let designVersion: Int = 1
   
    static var presetTags: Set<IGTag> {
        [
            IGTag("I ♥", scope: .design, isPreset: true),
            IGTag("I Heart", scope: .design, isPreset: true),
            IGTag("I Love", scope: .design, isPreset: true),
        ]
    }
    
    static func displayText(for phrase: String) -> String {
        "I ♥ \(phrase)"
    }
    
    static func drawLayout(
        of phrase: String,
        at size: CGSize,
        with theme: Theme,
        into context: CGContext
    ) {
        let font = theme.textFont
        let padding = max(size.width, size.height) * 0.05
        let innerSize = CGSize(
            width: size.width - padding,
            height: size.height - padding
        )
        let lineHeight = 0.30 * min(innerSize.width, innerSize.height)
        let iHeartSpacing = lineHeight * 0.15
        let heartHeight = lineHeight

        var iBlock = IGTextBlock(
            text: "I",
            fontName: font.rawValue,
            pointSize: lineHeight,
            color: theme.textColor
        )
        
        iBlock.scaleToMatchGlyphHeight(lineHeight)

        let iHeartWidth = iBlock.width + iHeartSpacing + heartHeight
        let iX = (size.width - iHeartWidth) / 2
        let heartX = iX + iBlock.width + iHeartSpacing

        let phraseText = phrase.uppercased()
        var phraseBlock = IGTextBlock(
            text: phraseText,
            fontName: font.rawValue,
            pointSize: iBlock.pointSize,
            color: theme.textColor
        )

        if phraseBlock.width > innerSize.width {
            phraseBlock.scaleToFit(width: innerSize.width)
        } else if phraseBlock.width < iHeartWidth {
            phraseBlock.scaleToFit(width: iHeartWidth)
        }

        let verticalSpacing: CGFloat = 0
        let totalHeight = phraseBlock.height + verticalSpacing + lineHeight
        let verticalPadding = (size.height - totalHeight) / 2

        let phraseOrigin = CGPoint(
            x: (size.width - phraseBlock.width) / 2,
            y: verticalPadding
        )

        let iOrigin = CGPoint(
            x: iX,
            y: phraseOrigin.y + phraseBlock.height + verticalSpacing
        )

        let heartOrigin = CGPoint(
            x: heartX,
            y: iOrigin.y
        )

        phraseBlock.draw(at: phraseOrigin, in: context)
        iBlock.draw(at: iOrigin, in: context)
        IHHeartShape.draw(at: heartOrigin, size: heartHeight, color: theme.heartColor, in: context)
        
    }
}
