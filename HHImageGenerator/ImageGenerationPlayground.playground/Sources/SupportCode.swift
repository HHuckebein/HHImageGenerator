//
// This file (and all other Swift source files in the Sources directory of this playground) will be precompiled into a framework which is automatically made available to ImageGenerationPlayground.playground.
//
//
//  HHImageGenerator.swift
//  HHImageGenerator
//
//  Created by Bernd Rabe on 06.09.15.
//  Copyright (c) 2015 RABE_IT Services. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit
import GLKit

public enum HHImageTypeIdentifier: Int {
    case Rectangle
    case Circle
    case CircleWithRightBar
    case RectangleWithStripesRight // use with .. dashPattern method
    case RectangleWithStripesLeft // use with .. dashPattern method
    case RectangleBordered
}

public enum HHImageRotation {
    case Unknown
    case Angle90
    case Angle180
    case Angle270
}

public struct HHRectBorder : RawOptionSetType {
    typealias RawValue = UInt
    private var value: UInt = 0
    
    init(_ value: UInt) { self.value = value }
    
    // MARK: _RawOptionSetType
    public init(rawValue value: UInt) { self.value = value }
    
    // MARK: NilLiteralConvertible
    public init(nilLiteral: ()) { self.value = 0 }
    
    // MARK: BitwiseOperationsType
    public static var allZeros: HHRectBorder { return self(0) }
    
    static func fromMask(raw: UInt) -> HHRectBorder { return self(raw) }
    
    // MARK: RawRepresentable
    public var rawValue: UInt { return self.value }
    
    public static var None: HHRectBorder       { return self(0) }
    public static var Top: HHRectBorder        { return HHRectBorder(1 << 0) }
    public static var Left: HHRectBorder       { return HHRectBorder(1 << 1) }
    public static var Right: HHRectBorder      { return HHRectBorder(1 << 2) }
    public static var Bottom: HHRectBorder     { return HHRectBorder(1 << 3) }
    public static var AllCorners: HHRectBorder { return HHRectBorder(~0) }
}

public struct HHImageGenerator {
    
    /** Generates an image as specified with the parameters and scale factor.
    :param: size    The size of the image.
    :param: color The stroke color of the strips if one of the stripes identifier is used. Otherwise the fill color of the shape.
    :param: backgroundColor The background color of the area outside the shape. Defaults to clear color.
    :param: identifier The identifier to define the shape
    :returns: image The generated image in the devices' scale.
    */
    
    public static func imageWithSize (size: CGSize, color: UIColor, backgroundColor: UIColor?, lineWidth: CGFloat, gap: CGFloat, identifier: HHImageTypeIdentifier) -> UIImage? {
        
        if CGSizeEqualToSize(size, CGSizeZero) {
            return nil
        }
        
        let isOpaque = (backgroundColor != nil) ? true : false
        let rect = CGRectMake(0.0, 0.0, size.width, size.height)
        UIGraphicsBeginImageContextWithOptions(size, isOpaque, 0.0)
        let context = UIGraphicsGetCurrentContext()
        if isOpaque {
            backgroundColor?.set()
            CGContextFillRect(context, rect)
        }
        
        CGContextSetFillColorWithColor(context, color.CGColor)
        switch identifier {
        case .Circle: CGContextFillEllipseInRect(context, rect)
            
        case .Rectangle: CGContextFillRect(context, rect)
            
        case .CircleWithRightBar:
            let radius = floor(min(size.width, size.height) / 2.0)
            var yOrigin = (size.height - radius) / 2.0
            let xOrigin = radius / 2
            CGContextFillEllipseInRect(context, CGRectMake(xOrigin, yOrigin, radius, radius))
            
            let barHeight = CGFloat(2.0)
            yOrigin = (size.height - barHeight) / 2.0
            CGContextFillRect(context, CGRectMake(xOrigin, yOrigin, radius, radius))
            
        case .RectangleWithStripesLeft: fallthrough
        case .RectangleWithStripesRight:
            var xPos: CGFloat = 0.0
            let xOffset = CGFloat(tanf(GLKMathDegreesToRadians(45.0))) * size.height
            let margin = lineWidth / 2.0 * CGFloat(sinf(GLKMathDegreesToRadians(45.0)))
            let minYPos = -margin
            let maxYPos = size.height + margin
            CGContextSetStrokeColorWithColor(context, color.CGColor)
            CGContextSetLineWidth(context, lineWidth)
            
            let number = Int(ceil(size.width + xOffset) / (gap + lineWidth))
            for index in 0...number {
                if identifier == .RectangleWithStripesRight {
                    xPos = CGFloat(index) * (lineWidth + gap) - xOffset
                    CGContextMoveToPoint(context, xPos - margin, minYPos)
                    xPos += xOffset
                    CGContextAddLineToPoint(context, xPos + margin, maxYPos)
                } else {
                    xPos = CGFloat(index) * (lineWidth + gap)
                    CGContextMoveToPoint(context, xPos + margin, minYPos)
                    xPos -= xOffset
                    CGContextAddLineToPoint(context, xPos - margin, maxYPos)
                }
            }
            CGContextDrawPath(context, kCGPathStroke)
            
        case .RectangleBordered:
            let lineWidth = min(size.width, size.height) * 2.0
            CGContextSetLineWidth(context, lineWidth)
            let path = UIBezierPath(rect: rect).CGPath
            CGContextAddPath(context, path)
            CGContextSetStrokeColorWithColor(context, color.CGColor);
            CGContextDrawPath(context, kCGPathStroke);
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    public static func imageWithSize (size: CGSize, color: UIColor, backgroundColor: UIColor?, identifier: HHImageTypeIdentifier) -> UIImage? {
        if CGSizeEqualToSize(size, CGSizeZero) {
            return nil
        }
        return HHImageGenerator.imageWithSize(size, color: color, backgroundColor: backgroundColor, lineWidth: 2.0, gap: 3.0, identifier: identifier)
    }
    
    public static func imageWithSize(size: CGSize, color: UIColor, backgroundColor: UIColor?,  dashPattern: Array<CGFloat>?, identifier: HHImageTypeIdentifier) -> UIImage? {
        if CGSizeEqualToSize(size, CGSizeZero) {
            return nil
        }
        
        if let pattern = dashPattern {
            return HHImageGenerator.imageWithSize(size, color: color, backgroundColor: backgroundColor, lineWidth: pattern[0], gap: pattern[1], identifier: identifier)
        }
        return HHImageGenerator.imageWithSize(size, color: color, backgroundColor: backgroundColor, lineWidth: 2.0, gap: 3.0, identifier: identifier)
    }
    
    public static func rotatedImage(image: UIImage, rotationAngle: Float) -> UIImage {
        
        let helperView = UIView(frame: CGRectMake(0,0, image.size.width, image.size.height))
        let transform = CGAffineTransformMakeRotation(CGFloat(rotationAngle))
        helperView.transform = transform
        let rotatedSize = helperView.frame.size;
        
        UIGraphicsBeginImageContext(rotatedSize);
        let context = UIGraphicsGetCurrentContext();
        
        CGContextTranslateCTM(context, rotatedSize.width/2, rotatedSize.height/2)
        CGContextRotateCTM(context, CGFloat(rotationAngle))
        
        CGContextScaleCTM(context, 1.0, -1.0)
        CGContextDrawImage(context, CGRectMake(-image.size.width / 2, -image.size.height / 2, image.size.width, image.size.height), image.CGImage)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    public static func scaledImage(image: UIImage, scale: CGFloat) -> UIImage {
        let ratio = min(image.size.width, image.size.height) * scale
        let rect  = CGRectMake(0.0, 0.0, ratio * image.size.width, ratio * image.size.height)
        UIGraphicsBeginImageContext(rect.size)
        image.drawInRect(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    public static func imageWithSize (size: CGSize, borders: HHRectBorder,  color: UIColor, backgroundColor: UIColor?, lineWidth: CGFloat) -> UIImage? {
        if CGSizeEqualToSize(size, CGSizeZero) {
            return nil
        }
        
        let isOpaque = (backgroundColor != nil) ? true : false
        let rect = CGRectMake(0.0, 0.0, size.width, size.height)
        
        UIGraphicsBeginImageContextWithOptions(size, isOpaque, 0.0)
        let context = UIGraphicsGetCurrentContext()
        
        if isOpaque {
            backgroundColor?.set()
            CGContextFillRect(context, rect)
        }
        
        CGContextSetLineWidth(context, lineWidth)
        CGContextSetStrokeColorWithColor(context, color.CGColor)
        
        var path = UIBezierPath()
        path.lineJoinStyle = kCGLineJoinRound
        
        if borders == .AllCorners {
            path = UIBezierPath(rect: rect)
        } else {
            if borders & HHRectBorder.Top != nil {
                path.moveToPoint(CGPointZero)
                path.addLineToPoint(CGPointMake(size.width, 0.0))
            }
            if borders & HHRectBorder.Right != nil {
                path.moveToPoint(CGPointMake(size.width, 0.0))
                path.addLineToPoint(CGPointMake(size.width, size.height))
            }
            if borders & HHRectBorder.Bottom  != nil{
                path.moveToPoint(CGPointMake(size.width, size.height))
                path.addLineToPoint(CGPointMake(0.0, size.height))
            }
            if borders & HHRectBorder.Left != nil {
                path.moveToPoint(CGPointMake(0.0, size.height))
                path.addLineToPoint(CGPointMake(0.0, 0.0))
            }
        }
        CGContextAddPath(context, path.CGPath)
        CGContextDrawPath(context, kCGPathStroke);
        
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return image;
        
    }
    
    public static func imageWithSize (size: CGSize, corners: UIRectCorner, cornerRadii: CGSize, color: UIColor, backgroundColor: UIColor?, lineWidth: CGFloat) -> UIImage? {
        if CGSizeEqualToSize(size, CGSizeZero) {
            return nil
        }
        
        let isOpaque = (backgroundColor != nil) ? true : false
        var rect = CGRectMake(0.0, 0.0, size.width, size.height)
        
        UIGraphicsBeginImageContextWithOptions(size, isOpaque, 0.0)
        let context = UIGraphicsGetCurrentContext()
        
        if isOpaque {
            backgroundColor?.set()
            CGContextFillRect(context, rect)
        }
        
        CGContextSetLineWidth(context, lineWidth)
        
        rect = CGRectMake(lineWidth / 2, lineWidth / 2, size.width -  lineWidth, size.height - lineWidth);
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: cornerRadii)

        CGContextSetLineCap(context, kCGLineCapSquare)
        CGContextAddPath(context, path.CGPath)
        
        CGContextSetStrokeColorWithColor(context, color.CGColor);
        CGContextDrawPath(context, kCGPathStroke);
        
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return image;
        
    }
    
    public static func imageWithSize (size: CGSize, outerRadius: CGFloat, innerRadius: CGFloat, color: UIColor, backgroundColor: UIColor?) -> UIImage? {
        if CGSizeEqualToSize(size, CGSizeZero) {
            return nil
        }
        
        let isOpaque = (backgroundColor != nil) ? true : false
        var rect = CGRectMake(0.0, 0.0, size.width, size.height)
        
        UIGraphicsBeginImageContextWithOptions(size, isOpaque, 0.0)
        
        let context = UIGraphicsGetCurrentContext()
        
        if isOpaque {
            backgroundColor?.set()
            CGContextFillRect(context, rect)
        }
        
        CGContextSetFillColorWithColor(context, color.CGColor)
        let center = CGPointMake(size.width / 2, size.height / 2)
        var path = UIBezierPath(arcCenter: center, radius: outerRadius, startAngle: CGFloat(0.0), endAngle: CGFloat(2 * M_PI), clockwise: false)
        path.addArcWithCenter(center, radius: innerRadius, startAngle: CGFloat(0.0), endAngle: CGFloat(2 * M_PI), clockwise: true)
        
        CGContextAddPath(context, path.CGPath);
        CGContextDrawPath(context, kCGPathEOFill);
        
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return image;
        
    }
    
    public static func starWithSize (size: CGSize, numberOfBeams: Int, scale: CGFloat, color: UIColor, backgroundColor: UIColor?) -> UIImage? {
        if CGSizeEqualToSize(size, CGSizeZero) || numberOfBeams == 0 || fabsf(Float(scale) - Float(1.0)) < FLT_EPSILON {
            return nil
        }
        
        let isOpaque = (backgroundColor != nil) ? true : false
        var rect = CGRectMake(0.0, 0.0, size.width, size.height)
        
        UIGraphicsBeginImageContextWithOptions(size, isOpaque, 0.0)
        let context = UIGraphicsGetCurrentContext()
        
        if isOpaque {
            backgroundColor?.set()
            CGContextFillRect(context, rect)
        }
        
        let outerRadius = min(size.width, size.height) / 2
        let innerRadius = outerRadius * scale
        
        let totalNumberOfPoints = numberOfBeams * 2
        var angle = 2 * M_PI  / Double(totalNumberOfPoints)
        
        var m = tan(angle)
        var innerPoint = CGPoint(x: innerRadius * CGFloat(cos(-angle)), y: innerRadius * CGFloat(sin(-angle)))
        var outerPoint = CGPointZero
        
        CGContextTranslateCTM(context, size.width / 2.0, size.height / 2.0)
        CGContextRotateCTM(context, CGFloat(-M_PI_2))
        
        var path = UIBezierPath()
        path.moveToPoint(innerPoint)
        for i in 0..<totalNumberOfPoints {
            if i % 2 == 1 {
                innerPoint.x = innerRadius * CGFloat(cos(Double(i) * angle))
                innerPoint.y = innerRadius * CGFloat(sin(Double(i) * angle))
                path.addLineToPoint(innerPoint)
            } else {
                outerPoint.x = outerRadius * CGFloat(cos(Double(i) * angle))
                outerPoint.y = outerRadius * CGFloat(sin(Double(i) * angle))
                path.addLineToPoint(outerPoint)
            }
        }
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextAddPath(context, path.CGPath)
        CGContextDrawPath(context, kCGPathFill)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        
        return image;
    }
}