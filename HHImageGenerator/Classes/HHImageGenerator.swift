//
//  HHImageGenerator.swift
//  HHImageGenerator
//
//  Created by Bernd Rabe on 06.09.15.
//  Copyright (c) 2015 RABE_IT Services. All rights reserved.
//

import UIKit
import GLKit

public enum HHImageTypeIdentifier: Int {
    case rectangle
    case circle
    case circleWithRightBar
    case rectangleWithStripesRight // use with .. dashPattern method
    case rectangleWithStripesLeft // use with .. dashPattern method
    case rectangleBordered
}

public struct HHRectBorder : OptionSet {
    public typealias RawValue = UInt
    fileprivate var value: UInt = 0
    
    init(_ value: UInt) { self.value = value }
    
    // MARK: _RawOptionSetType
    public init(rawValue value: UInt) { self.value = value }
    
    // MARK: NilLiteralConvertible
    init(nilLiteral: ()) { self.value = 0 }
    
    // MARK: BitwiseOperationsType
    static var allZeros: HHRectBorder { return self.init(0) }
    
    static func fromMask(_ raw: UInt) -> HHRectBorder { return self.init(raw) }
    
    // MARK: RawRepresentable
    public var rawValue: UInt { return self.value }
    
    static var None: HHRectBorder       { return self.init(0) }
    static var Top: HHRectBorder        { return HHRectBorder(1 << 0) }
    static var Left: HHRectBorder       { return HHRectBorder(1 << 1) }
    static var Right: HHRectBorder      { return HHRectBorder(1 << 2) }
    static var Bottom: HHRectBorder     { return HHRectBorder(1 << 3) }
    static var AllCorners: HHRectBorder { return HHRectBorder(~0) }
}

extension UIImage {
    
    /** Generates an image as specified with the parameters and scale factor.
     - parameter size:    The size of the image.
     - parameter color: The stroke color of the strips if one of the stripes identifier is used. Otherwise the fill color of the shape.
     - parameter backgroundColor: The background color of the area outside the shape. Defaults to clear color.
     - parameter identifier: The identifier to define the shape
     - returns: image The generated image in the devices' scale.
     */
    
    public convenience init?(withSize size: CGSize, color: UIColor, backgroundColor: UIColor? = nil, lineWidth: CGFloat, gap: CGFloat, identifier: HHImageTypeIdentifier) {
        if size.equalTo(CGSize.zero) {
            return nil
        }
        
        let isOpaque = (backgroundColor != nil)
        let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, isOpaque, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        if isOpaque {
            backgroundColor?.set()
            context.fill(rect)
        }
        
        context.setFillColor(color.cgColor)
        switch identifier {
        case .circle: context.fillEllipse(in: rect)
            
        case .rectangle: context.fill(rect)
            
        case .circleWithRightBar:
            let radius = floor(min(size.width, size.height) / 2.0)
            var yOrigin = (size.height - radius) / 2.0
            let xOrigin = radius / 2
            context.fillEllipse(in: CGRect(x: xOrigin, y: yOrigin, width: radius, height: radius))
            
            let barHeight = CGFloat(2.0)
            yOrigin = (size.height - barHeight) / 2.0
            context.fill(CGRect(x: xOrigin, y: yOrigin, width: radius, height: radius))
            
            /** Drawing happens to start/end outside of the visible area (rect) so
             that the complete rectangle is filled.
             */
        case .rectangleWithStripesLeft: fallthrough
        case .rectangleWithStripesRight:
            //            var xPos: CGFloat = 0.0
            let angle = GLKMathDegreesToRadians(45.0)
            /** This is where we would start drawing with line width zero.
             Needs to be correct by line width.
             */
            let xOffset = CGFloat(tanf(angle)) * size.height
            let adjustment = lineWidth / 2.0 * CGFloat(sinf(angle))
            /** Adjustment applies to x and y position as this is an equilateral triangle (45°)
             Think of the line as an rectangular stripes to be positioned. 0/0 is the top left corner.
             */
            let minYPos = -adjustment
            let maxYPos = size.height + adjustment
            
            context.setStrokeColor(color.cgColor)
            context.setLineWidth(lineWidth)
            
            /** Calculate the total number of lines to be drawn.
             Consider a pair of line + gap as one unit.
             */
            var startPoint = CGPoint(x: 0, y: minYPos)
            var endPoint   = CGPoint(x: 0, y: maxYPos)
            let number = Int(ceil(size.width + xOffset) / (lineWidth + gap))
            for index in 0...number {
                if identifier == .rectangleWithStripesRight {
                    // drawing goes from lower left to upper RIGHT direction
                    startPoint.x = CGFloat(index) * (lineWidth + gap) - xOffset - adjustment
                    endPoint.x   = CGFloat(index) * (lineWidth + gap) + adjustment
                    context.move(to: CGPoint(x: startPoint.x, y: startPoint.y))
                    context.addLine(to: CGPoint(x: endPoint.x, y: endPoint.y))
                } else {
                    startPoint.x = CGFloat(index) * (lineWidth + gap) + adjustment
                    endPoint.x   = CGFloat(index) * (lineWidth + gap) - xOffset
                    context.move(to: CGPoint(x: startPoint.x, y: startPoint.y))
                    context.addLine(to: CGPoint(x: endPoint.x, y: endPoint.y))
                }
            }
            context.drawPath(using: CGPathDrawingMode.stroke)
            
        case .rectangleBordered:
            let lineWidth = min(size.width, size.height) * 2.0
            context.setLineWidth(lineWidth)
            let path = UIBezierPath(rect: rect).cgPath
            context.addPath(path)
            context.setStrokeColor(color.cgColor)
            context.drawPath(using: CGPathDrawingMode.stroke)
        }
        
        guard let cgImage = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else {
            UIGraphicsEndImageContext()
            return nil
        }
        UIGraphicsEndImageContext()
        self.init(cgImage: cgImage)
    }
    
    public convenience init?(circleWithSize size: CGSize, color: UIColor, backgroundColor: UIColor? = nil)  {
        self.init(withSize: size, color: color, backgroundColor: backgroundColor, lineWidth: 0, gap: 0, identifier: .circle)
    }
    
    public convenience init?(rectangleWithSize size: CGSize, color: UIColor, backgroundColor: UIColor? = nil)  {
        self.init(withSize: size, color: color, backgroundColor: backgroundColor, lineWidth: 0, gap: 0, identifier: .rectangle)
    }
    
    public convenience init?(withDashPattern pattern: Array<CGFloat>, size: CGSize, color: UIColor, backgroundColor: UIColor? = nil, identifier: HHImageTypeIdentifier) {
        if size.equalTo(CGSize.zero) || pattern.count < 2 {
            return nil
        }
        
        self.init(withSize: size, color: color, backgroundColor: backgroundColor, lineWidth: pattern[0], gap: pattern[1], identifier: identifier)
    }
    
    public convenience init?(withBorders borders: HHRectBorder, borderWidth: CGFloat, size: CGSize,  color: UIColor, backgroundColor: UIColor? = nil) {
        if size.equalTo(CGSize.zero) {
            return nil
        }
        
        let isOpaque = (backgroundColor != nil) ? true : false
        let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        
        UIGraphicsBeginImageContextWithOptions(size, isOpaque, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        if isOpaque {
            backgroundColor?.set()
            context.fill(rect)
        }
        
        context.setLineWidth(borderWidth)
        context.setStrokeColor(color.cgColor)
        
        var path = UIBezierPath()
        path.lineJoinStyle = CGLineJoin.round
        
        if borders == .AllCorners {
            path = UIBezierPath(rect: rect)
        } else {
            if borders.intersection(HHRectBorder.Top) != [] {
                path.move(to: CGPoint.zero)
                path.addLine(to: CGPoint(x: size.width, y: 0.0))
            }
            if borders.intersection(HHRectBorder.Right) != [] {
                path.move(to: CGPoint(x: size.width, y: 0.0))
                path.addLine(to: CGPoint(x: size.width, y: size.height))
            }
            if borders.intersection(HHRectBorder.Bottom)  != []{
                path.move(to: CGPoint(x: size.width, y: size.height))
                path.addLine(to: CGPoint(x: 0.0, y: size.height))
            }
            if borders.intersection(HHRectBorder.Left) != [] {
                path.move(to: CGPoint(x: 0.0, y: size.height))
                path.addLine(to: CGPoint(x: 0.0, y: 0.0))
            }
        }
        context.addPath(path.cgPath)
        context.drawPath(using: CGPathDrawingMode.stroke)
        
        guard let cgImage = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else {
            UIGraphicsEndImageContext()
            return nil
        }
        UIGraphicsEndImageContext()
        self.init(cgImage: cgImage)
    }
    
    public convenience init?(withCorners corners: UIRectCorner, cornerRadii: CGSize, borderWidth: CGFloat, size: CGSize, color: UIColor, backgroundColor: UIColor? = nil) {
        if size.equalTo(CGSize.zero) {
            return nil
        }
        
        let isOpaque = (backgroundColor != nil) ? true : false
        var rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        
        UIGraphicsBeginImageContextWithOptions(size, isOpaque, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        if isOpaque {
            backgroundColor?.set()
            context.fill(rect)
        }
        
        context.setLineWidth(borderWidth)
        
        rect = CGRect(x: borderWidth / 2, y: borderWidth / 2, width: size.width -  borderWidth, height: size.height - borderWidth)
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: cornerRadii)
        
        context.setLineCap(CGLineCap.square)
        context.addPath(path.cgPath)
        
        context.setStrokeColor(color.cgColor)
        context.drawPath(using: CGPathDrawingMode.stroke)
        
        guard let cgImage = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else {
            UIGraphicsEndImageContext()
            return nil
        }
        UIGraphicsEndImageContext()
        self.init(cgImage: cgImage)
    }
    
    public convenience init?(ringWithSize size: CGSize, outerRadius: CGFloat, innerRadius: CGFloat, color: UIColor, backgroundColor: UIColor? = nil) {
        if size.equalTo(CGSize.zero) {
            return nil
        }
        
        let isOpaque = (backgroundColor != nil) ? true : false
        let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        
        UIGraphicsBeginImageContextWithOptions(size, isOpaque, 0.0)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        if isOpaque {
            backgroundColor?.set()
            context.fill(rect)
        }
        
        context.setFillColor(color.cgColor)
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let path = UIBezierPath(arcCenter: center, radius: outerRadius, startAngle: CGFloat(0.0), endAngle: CGFloat(2 * Double.pi), clockwise: false)
        path.addArc(withCenter: center, radius: innerRadius, startAngle: CGFloat(0.0), endAngle: CGFloat(2 * Double.pi), clockwise: true)
        
        context.addPath(path.cgPath)
        context.drawPath(using: CGPathDrawingMode.eoFill)
        
        guard let cgImage = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else {
            UIGraphicsEndImageContext()
            return nil
        }
        UIGraphicsEndImageContext()
        self.init(cgImage: cgImage)
    }
    
    /** Creates an image of the specified type `identifier`.
     - parameter size: - The size of the  image.
     - parameter color: - The image color.
     - parameter backgroundColor: - If present used as background color or as paint color if a `character` is specified. nil makes a transparent background.
     - parameter character: - A string which is drawn centered in the image. Color defaults to white if no `backgroundColor` is specified.
     - parameter fontName: - The font name to be used if a character string is specified.
     - parameter fontSize: - The font size.
     - parameter identifier: - Specifies the type of image.
     :return: The rendered image in the device scale.
     */
    
    public convenience init?(withCharacter character: String, fontName: String = "Helevetica", fontSize: CGFloat = 17.0, size: CGSize, color: UIColor, backgroundColor: UIColor? = nil, identifier: HHImageTypeIdentifier) {
        if size.equalTo(CGSize.zero) {
            return nil
        }
        
        let isOpaque = (backgroundColor != nil) && character.isEmpty
        let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, isOpaque, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        if isOpaque {
            backgroundColor?.set()
            context.fill(rect)
        }
        
        context.setFillColor(color.cgColor)
        switch identifier {
        case .circle:    context.fillEllipse(in: rect)
        case .rectangle: context.fill(rect)
        default: return nil
        }
        
        if character.isEmpty == false {
            context.saveGState()
            if let characterColor = backgroundColor {
                context.setFillColor(characterColor.cgColor)
            }
            else {
                context.setFillColor(UIColor.white.cgColor)
            }
            
            let path = UIImage.outlinePathForString(character, fontName: fontName, fontSize: fontSize)
            let frame = path.cgPath.boundingBox
            let offsetX: CGFloat = (size.width  - frame.width)  / 2.0 - frame.minX
            let offsetY: CGFloat = (size.height - frame.height) / 2.0 - frame.minY
            context.translateBy(x: offsetX, y: offsetY)
            context.addPath(path.cgPath)
            context.drawPath(using: CGPathDrawingMode.fill)
        }
        
        guard let cgImage = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else {
            UIGraphicsEndImageContext()
            return nil
        }
        UIGraphicsEndImageContext()
        self.init(cgImage: cgImage)
    }
    
    public convenience init?(withSize size: CGSize, numberOfBeams: Int, scale: CGFloat, color: UIColor, backgroundColor: UIColor? = nil) {
        if size.equalTo(CGSize.zero) || numberOfBeams == 0 || fabsf(Float(scale) - Float(1.0)) < Float.ulpOfOne {
            return nil
        }
        
        let isOpaque = (backgroundColor != nil) ? true : false
        let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        
        UIGraphicsBeginImageContextWithOptions(size, isOpaque, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        if isOpaque {
            backgroundColor?.set()
            context.fill(rect)
        }
        
        let outerRadius = min(size.width, size.height) / 2
        let innerRadius = outerRadius * scale
        
        let totalNumberOfPoints = numberOfBeams * 2
        let angle = 2 * Double.pi / Double(totalNumberOfPoints)
        
        _ = tan(angle)
        var innerPoint = CGPoint(x: innerRadius * CGFloat(cos(-angle)), y: innerRadius * CGFloat(sin(-angle)))
        var outerPoint = CGPoint.zero
        
        context.translateBy(x: size.width / 2.0, y: size.height / 2.0)
        context.rotate(by: CGFloat(-Double.pi/2))
        
        let path = UIBezierPath()
        path.move(to: innerPoint)
        for i in 0..<totalNumberOfPoints {
            if i % 2 == 1 {
                innerPoint.x = innerRadius * CGFloat(cos(Double(i) * angle))
                innerPoint.y = innerRadius * CGFloat(sin(Double(i) * angle))
                path.addLine(to: innerPoint)
            } else {
                outerPoint.x = outerRadius * CGFloat(cos(Double(i) * angle))
                outerPoint.y = outerRadius * CGFloat(sin(Double(i) * angle))
                path.addLine(to: outerPoint)
            }
        }
        context.setFillColor(color.cgColor)
        context.addPath(path.cgPath)
        context.drawPath(using: CGPathDrawingMode.fill)
        
        guard let cgImage = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else {
            UIGraphicsEndImageContext()
            return nil
        }
        UIGraphicsEndImageContext()
        self.init(cgImage: cgImage)
    }
    
    /** Creates the outline path of a given string/character.
     NOTE: One must correct the CTM (current transformation matrix)
     with the bounding box's frame/origing, to have the path correctly
     rendered.
     let frame = CGPathGetBoundingBox(drawingPath.CGPath)
     CGContextTranslateCTM(context, -CGRectGetMinX(frame), -CGRectGetMinY(frame))
     */
    static fileprivate func outlinePathForString (_ string: String, fontName: String, fontSize: CGFloat) -> UIBezierPath {
        let bezierPath = UIBezierPath()
        if let font = UIFont (name: fontName, size: fontSize), string.isEmpty == false {
            let attrString = NSAttributedString(string: string, attributes: [NSFontAttributeName : font])
            let line       = CTLineCreateWithAttributedString(attrString)
            let runArray   = CTLineGetGlyphRuns(line) as! Array<CTRun>
            
            let run: CTRun = unsafeBitCast(CFArrayGetValueAtIndex(runArray as CFArray, 0), to: CTRun.self)
            
            var glyph          = CGGlyph()
            var position       = CGPoint.zero
            var thisGlyphRange = CFRange()
            let baseTransform  = CGAffineTransform(scaleX: 1.0, y: -1.0)
            
            for runGlyphIndex in 0 ..< CTRunGetGlyphCount(run) {
                thisGlyphRange = CFRangeMake(runGlyphIndex, 1)
                
                CTRunGetGlyphs(run, thisGlyphRange, &glyph)
                CTRunGetPositions(run, thisGlyphRange, &position)
                var transform = baseTransform.translatedBy(x: position.x, y: position.y)
                if let characterPath = CTFontCreatePathForGlyph(font, glyph, &transform) {
                    bezierPath.append(UIBezierPath(cgPath: characterPath))
                }
            }
        }
        return bezierPath
    }
}

extension UIImage {
    public func rotate(by rotationAngle: Float) -> UIImage? {
        let helperView = UIView(frame: CGRect(x: 0,y: 0, width: self.size.width, height: self.size.height))
        let transform = CGAffineTransform(rotationAngle: CGFloat(rotationAngle))
        helperView.transform = transform
        let rotatedSize = helperView.frame.size
        
        UIGraphicsBeginImageContext(rotatedSize)
        guard let context = UIGraphicsGetCurrentContext(), let cgImage = self.cgImage else {
            return nil
        }
        
        context.translateBy(x: rotatedSize.width/2, y: rotatedSize.height/2)
        context.rotate(by: CGFloat(rotationAngle))
        
        context.scaleBy(x: 1.0, y: -1.0)
        context.draw(cgImage, in: CGRect(x: -self.size.width / 2, y: -self.size.height / 2, width: self.size.width, height: self.size.height))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    public func scaled(by scale: CGFloat) -> UIImage? {
        let ratio = min(self.size.width, self.size.height) * scale
        let rect  = CGRect(x: 0.0, y: 0.0, width: ratio * self.size.width, height: ratio * self.size.height)
        UIGraphicsBeginImageContext(rect.size)
        self.draw(in: rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}
