//
//  IGColor.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-12-17.
//

import Foundation
import SwiftUI

struct IGColor {
    let name: String
    let red: Double
    let green: Double
    let blue: Double
    let alpha: Double

    init(
        _ name: String = "",
        red: Double,
        green: Double,
        blue: Double,
        alpha: Double = 1
    ) {
        precondition((0...1).contains(red))
        precondition((0...1).contains(green))
        precondition((0...1).contains(blue))
        precondition((0...1).contains(alpha))

        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
        self.name = name
    }
}

extension IGColor {
    static var black: Self { IGColor("black", red: 0, green: 0, blue: 0) }
    static var white: Self { IGColor("white", red: 1, green: 1, blue: 1) }
    static var red: Self { IGColor("red", red: 1, green: 0, blue: 0) }
}

extension IGColor: Hashable { }

extension IGColor: Codable { }

extension IGColor: Identifiable {
    var id: String {
        let r = Int((red * 255).rounded())
        let g = Int((green * 255).rounded())
        let b = Int((blue * 255).rounded())
        let a = Int((alpha * 255).rounded())
        return "\(r)-\(g)-\(b)-\(a)"
    }
}

extension IGColor {
    @MainActor
    var swiftUIColor: Color {
        Color(red: red, green: green, blue: blue, opacity: alpha)
    }
}

extension IGColor {

    private static let sRGBColorSpace: CGColorSpace = {
        guard let space = CGColorSpace(name: CGColorSpace.sRGB) else {
            preconditionFailure("sRGB color space must be available")
        }
        return space
    }()

    var cgColor: CGColor {
        guard let color = CGColor(
            colorSpace: Self.sRGBColorSpace,
            components: [
                CGFloat(red),
                CGFloat(green),
                CGFloat(blue),
                CGFloat(alpha)
            ]
        ) else {
            preconditionFailure("Failed to create CGColor from IGColor components")
        }
        return color
    }
}
