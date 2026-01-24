//
//  IGHeartShape.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2024-07-21.
//

import CoreGraphics

enum IHHeartShape {
    
    static func draw(
        at origin: CGPoint,
        size: CGFloat,
        color: IGColor,
        in context: CGContext
    ) {
        let width = size
        let height = size
        let ox = origin.x + width * 0.5
        let oy = origin.y

        let y1 = height * 0.70
        let y2 = height
        let x1 = width * 0.25
        let x2 = width * 0.5
        
        let heartDipHeight = y2 * 0.80
        let bottomBend = y1 * 0.45
        let topOutsideBend = (x2 - x1) * 0.65
        let edgeOutsideBend = (y2 - y1) * 0.65
        let topInsideBend = x1 * 0.25
        
        let start = CGPoint(x: ox, y: oy)
        
        let p1 = CGPoint(x: ox - x2, y: oy + y1)
        let cp1a = CGPoint(x: ox, y: oy)
        let cp1b = CGPoint(x: ox - x2, y: oy + bottomBend)
       
        let p2 = CGPoint(x: ox - x1, y: oy + y2)
        let cp2a = CGPoint(x: ox - x2, y: oy + y1 + edgeOutsideBend)
        let cp2b = CGPoint(x: ox - x1 - topOutsideBend, y: oy + y2)
       
        let p3 = CGPoint(x: ox, y: oy + heartDipHeight)
        let cp3a = CGPoint(x: ox - topInsideBend, y: oy + y2)
        let cp3b = CGPoint(x: ox, y: oy + heartDipHeight)
        
        let p4 = CGPoint(x: ox + x1, y: oy + y2)
        let cp4a = CGPoint(x: ox, y: oy + heartDipHeight)
        let cp4b = CGPoint(x: ox + topInsideBend, y: oy + y2)

        let p5 = CGPoint(x: ox + x2, y: oy + y1)
        let cp5a = CGPoint(x: ox + x1 + topOutsideBend, y: oy + y2)
        let cp5b = CGPoint(x: ox + x2, y: oy + y1 + edgeOutsideBend)

        let p6 = CGPoint(x: ox, y: oy)
        let cp6a = CGPoint(x: ox + x2, y: oy + bottomBend)
        let cp6b = CGPoint(x: ox, y: oy)
        
        context.saveGState()
        context.setFillColor(color.cgColor)

        context.beginPath()
        context.move(to: start)
        context.addCurve(to: p1, control1: cp1a, control2: cp1b)
        context.addCurve(to: p2, control1: cp2a, control2: cp2b)
        context.addCurve(to: p3, control1: cp3a, control2: cp3b)
        context.addCurve(to: p4, control1: cp4a, control2: cp4b)
        context.addCurve(to: p5, control1: cp5a, control2: cp5b)
        context.addCurve(to: p6, control1: cp6a, control2: cp6b)
        context.closePath()
        context.fillPath()
        context.restoreGState()
    }
}
