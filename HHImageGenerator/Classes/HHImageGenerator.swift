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

enum HHImageTypeIdentifier: Int {
    case Rectangle
    case Circle
    case CircleWithRightBar
    case RectangleWithStripesRight // use with .. dashPattern method
    case RectangleWithStripesLeft // use with .. dashPattern method
    case RectangleBordered
}

struct HHRectBorder : RawOptionSetType {
    typealias RawValue = UInt
    private var value: UInt = 0
    
    init(_ value: UInt) { self.value = value }
    
    // MARK: _RawOptionSetType
    init(rawValue value: UInt) { self.value = value }
    
    // MARK: NilLiteralConvertible
    init(nilLiteral: ()) { self.value = 0 }
    
    // MARK: BitwiseOperationsType
    static var allZeros: HHRectBorder { return self(0) }

    static func fromMask(raw: UInt) -> HHRectBorder { return self(raw) }
    
    // MARK: RawRepresentable
    var rawValue: UInt { return self.value }
    
    static var None: HHRectBorder       { return self(0) }
    static var Top: HHRectBorder        { return HHRectBorder(1 << 0) }
    static var Left: HHRectBorder       { return HHRectBorder(1 << 1) }
    static var Right: HHRectBorder      { return HHRectBorder(1 << 2) }
    static var Bottom: HHRectBorder     { return HHRectBorder(1 << 3) }
    static var AllCorners: HHRectBorder { return HHRectBorder(~0) }
}

struct HHImageGenerator {
    
    /** Generates an image as specified with the parameters and scale factor.
    :param: size    The size of the image.
    :param: color The stroke color of the strips if one of the stripes identifier is used. Otherwise the fill color of the shape.
    :param: backgroundColor The background color of the area outside the shape. Defaults to clear color.
    :param: identifier The identifier to define the shape
    :returns: image The generated image in the devices' scale.
    */

    static func imageWithSize (size: CGSize, color: UIColor, backgroundColor: UIColor?, lineWidth: CGFloat, gap: CGFloat, identifier: HHImageTypeIdentifier) -> UIImage? {
        
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
            for index in 0..<number {
                if identifier == .RectangleWithStripesRight {
                   xPos = CGFloat(index) * (lineWidth + gap) - xOffset
                    CGContextMoveToPoint(context, xPos, minYPos)
                    xPos += xOffset
                    CGContextAddLineToPoint(context, xPos + margin, maxYPos)
                } else {
                    xPos = CGFloat(index) * (lineWidth + gap)
                    CGContextMoveToPoint(context, xPos, minYPos)
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
    
    static func imageWithSize (size: CGSize, color: UIColor, backgroundColor: UIColor?, identifier: HHImageTypeIdentifier) -> UIImage? {
        if CGSizeEqualToSize(size, CGSizeZero) {
            return nil
        }
        return HHImageGenerator.imageWithSize(size, color: color, backgroundColor: backgroundColor, lineWidth: 2.0, gap: 3.0, identifier: identifier)
    }
    
    static func imageWithSize(size: CGSize, color: UIColor, backgroundColor: UIColor?,  dashPattern: Array<CGFloat>?, identifier: HHImageTypeIdentifier) -> UIImage? {
        if CGSizeEqualToSize(size, CGSizeZero) {
            return nil
        }
        
        if let pattern = dashPattern {
            return HHImageGenerator.imageWithSize(size, color: color, backgroundColor: backgroundColor, lineWidth: pattern[0], gap: pattern[1], identifier: identifier)
        }
        return HHImageGenerator.imageWithSize(size, color: color, backgroundColor: backgroundColor, lineWidth: 2.0, gap: 3.0, identifier: identifier)
    }
    
    static func imageWithSize (size: CGSize, borders: HHRectBorder,  color: UIColor, backgroundColor: UIColor?, lineWidth: CGFloat) -> UIImage? {
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
    
    static func imageWithSize (size: CGSize, corners: UIRectCorner, cornerRadii: CGSize, color: UIColor, backgroundColor: UIColor?, lineWidth: CGFloat) -> UIImage? {
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
    
    static func imageWithSize (size: CGSize, outerRadius: CGFloat, innerRadius: CGFloat, color: UIColor, backgroundColor: UIColor?) -> UIImage? {
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
    
    static func rotatedImage(image: UIImage, rotationAngle: Float) -> UIImage {
        
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
    
    static func scaledImage(image: UIImage, scale: CGFloat) -> UIImage {
        let ratio = min(image.size.width, image.size.height) * scale
        let rect  = CGRectMake(0.0, 0.0, ratio * image.size.width, ratio * image.size.height)
        UIGraphicsBeginImageContext(rect.size)
        image.drawInRect(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}