//: Playground - noun: a place where people can play

import UIKit

let size     = CGSize(width: 100.0, height: 100.0)
let halfSize = CGSize(width: 100.0, height: 50.0)

enum Orientation {
    case North, South
}

let orientation = Orientation.North
let frame = CGRect(origin: CGPoint.zero, size: size)

let halfDonut = UIBezierPath()
let d1 = orientation == .North ? CGFloat(Double.pi) : 0
let d2 = orientation == .North ? CGFloat(Double.pi * 2) : CGFloat(Double.pi)
halfDonut.addArc(withCenter: CGPoint(x: 50, y: 50), radius: 20, startAngle: d2, endAngle: d1, clockwise: false)
halfDonut.addArc(withCenter: CGPoint(x: 50, y: 50), radius: 50, startAngle: d1, endAngle: d2, clockwise: true)
halfDonut.close()

let shapeLayer = CAShapeLayer()
shapeLayer.frame = frame
shapeLayer.path = halfDonut.cgPath
shapeLayer.fillColor = UIColor.black.cgColor
shapeLayer.strokeColor = nil

let shapeView = UIView(frame: frame)
shapeView.layer.mask = shapeLayer
//view.layer.addSublayer(shapeLayer)
shapeView.backgroundColor = .orange

let some = HHImageGenerator.image(withCharacter: "+", fontName: "HelveticaNeue-Bold", fontSize: 150.0, size: size, color: .blue, backgroundColor: .yellow, identifier: .circle)

let circle = HHImageGenerator.circle(withSize: size, color: .red)

let rect = HHImageGenerator.rectangle(withSize: size, color: .red)


let ring = HHImageGenerator.ring(withSize: size, outerRadius: size.width/2, innerRadius: size.width/2 - 10, color: .orange)

let star = HHImageGenerator.star(withSize: size, numberOfBeams: 8, scale: 0.7, color: .green)




let rot = HHImageGenerator.rotatedImage(rect!, rotationAngle: 0.5)

let dash1 = HHImageGenerator.image(withDashPattern: [2, 6], size: size, color: .red, backgroundColor: .white, identifier: .rectangleWithStripesLeft)

