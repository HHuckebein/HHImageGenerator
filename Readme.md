# UIImage extension

Create sample assets (star, rectangle, circle, ring)on the fly.
See Playground for usage examples.


```swift
public convenience init?(circle size: CGSize, color: UIColor, backgroundColor: UIColor? = nil)

public convenience init?(rectangle size: CGSize, color: UIColor, backgroundColor: UIColor? = nil)

public convenience init?(star size: CGSize, numberOfBeams: Int, scale: CGFloat, color: UIColor, backgroundColor: UIColor? = nil)

public convenience init?(ring size: CGSize, outerRadius: CGFloat, innerRadius: CGFloat, color: UIColor, backgroundColor: UIColor? = nil)

public convenience init?(withDashPattern pattern: Array<CGFloat>, size: CGSize, color: UIColor, backgroundColor: UIColor? = nil, identifier: HHImageTypeIdentifier)

public convenience init?(withBorders borders: HHRectBorder, borderWidth: CGFloat, size: CGSize,  color: UIColor, backgroundColor: UIColor? = nil)

public convenience init?(withCorners corners: UIRectCorner, cornerRadii: CGSize, borderWidth: CGFloat, size: CGSize, color: UIColor, backgroundColor: UIColor? = nil)

public convenience init?(withString string: String, font: UIFont = UIFont.systemFont(ofSize: 17.0), size: CGSize, color: UIColor, backgroundColor: UIColor? = nil, identifier: HHImageTypeIdentifier)

public func rotate(by rotationAngle: Float) -> UIImage?

public func scaled(by scale: CGFloat) -> UIImage?

```
