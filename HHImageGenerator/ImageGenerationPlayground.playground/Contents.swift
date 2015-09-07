//: Playground - noun: a place where people can play

import UIKit
import GLKit

var str = "Hello, playground"

let imgRect = HHImageGenerator.imageWithSize(CGSize(width: 100.0, height: 100.0), color: UIColor.redColor(), backgroundColor: nil, identifier: .Rectangle)
let imgCircle = HHImageGenerator.imageWithSize(CGSize(width: 100.0, height: 100.0), color: UIColor.blueColor(), backgroundColor: UIColor.greenColor(), identifier: .Circle)

let imgCircleWRightBar = HHImageGenerator.imageWithSize(CGSize(width: 100.0, height: 100.0), color: UIColor.blueColor(), backgroundColor: UIColor.greenColor(), identifier: .CircleWithRightBar)
let imgDash1 = HHImageGenerator.imageWithSize(CGSizeMake(100.0, 100.0), color: UIColor.redColor(), backgroundColor: UIColor.whiteColor(), dashPattern: [10.0, 10.0], identifier: .RectangleWithStripesLeft)
let imgDash2 = HHImageGenerator.imageWithSize(CGSizeMake(100.0, 100.0), color: UIColor.redColor(), backgroundColor: UIColor.whiteColor(), dashPattern: [5.0, 10.0], identifier: .RectangleWithStripesRight)
let imgRot90 = HHImageGenerator.rotatedImage(imgCircleWRightBar!, rotationAngle: GLKMathDegreesToRadians(90.0))
let imgBorder = HHImageGenerator.imageWithSize(CGSizeMake(100.0, 100.0), outerRadius: 30.0, innerRadius: 10.0, color: UIColor.orangeColor(), backgroundColor: nil)
let imgBordersTop = HHImageGenerator.imageWithSize(CGSizeMake(100.0, 100.0), borders: .Top, color: UIColor.yellowColor(), backgroundColor: UIColor.blackColor(), lineWidth: 20.0)

let imgBordersRight = HHImageGenerator.imageWithSize(CGSizeMake(100.0, 100.0), borders: .Right, color: UIColor.yellowColor(), backgroundColor: UIColor.blackColor(), lineWidth: 20.0)

let imgBordersBottom = HHImageGenerator.imageWithSize(CGSizeMake(100.0, 100.0), borders: .Bottom, color: UIColor.yellowColor(), backgroundColor: UIColor.blackColor(), lineWidth: 20.0)

let imgBordersLeft = HHImageGenerator.imageWithSize(CGSizeMake(100.0, 100.0), borders: .Left, color: UIColor.yellowColor(), backgroundColor: UIColor.blackColor(), lineWidth: 20.0)
let imgBorders1 = HHImageGenerator.imageWithSize(CGSizeMake(100.0, 100.0), borders: .Bottom | .Top, color: UIColor.yellowColor(), backgroundColor: UIColor.blackColor(), lineWidth: 20.0)
let imgBorders2 = HHImageGenerator.imageWithSize(CGSizeMake(100.0, 100.0), borders: .AllCorners, color: UIColor.yellowColor(), backgroundColor: UIColor.blackColor(), lineWidth: 20.0)
let imgRoundedCorner = HHImageGenerator.imageWithSize(CGSizeMake(100, 50), corners: .BottomLeft, cornerRadii: CGSizeMake(10.0, 10.0), color: UIColor.purpleColor(), backgroundColor: nil, lineWidth: 10)

let view = UIView(frame: CGRectMake(0, 0, 400, 400))
view.backgroundColor = UIColor(patternImage: imgDash1!)

