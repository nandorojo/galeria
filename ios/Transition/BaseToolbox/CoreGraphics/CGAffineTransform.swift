import CoreGraphics

extension CGAffineTransform {
    @inlinable public var offset: CGPoint { CGPoint(x: tx, y: ty) }
    @inlinable public var scaleX: CGFloat { sqrt(a * a + c * c) }
    @inlinable public var scaleY: CGFloat { sqrt(b * b + d * d) }
    @inlinable public var rotation: CGFloat { atan2(b, a) }
    
    @inlinable public func translatedBy(x: CGFloat) -> CGAffineTransform {
        translatedBy(x: x, y: 0)
    }
    
    @inlinable public func translatedBy(y: CGFloat) -> CGAffineTransform {
        translatedBy(x: 0, y: y)
    }
    
    @inlinable public func translatedBy(_ point: CGPoint) -> CGAffineTransform {
        translatedBy(x: point.x, y: point.y)
    }
    
    @inlinable public func scaledBy(x: CGFloat) -> CGAffineTransform {
        scaledBy(x: x, y: 1)
    }
    
    @inlinable public func scaledBy(y: CGFloat) -> CGAffineTransform {
        scaledBy(x: 1, y: y)
    }
    
    @inlinable public func scaledBy(_ scale: CGFloat) -> CGAffineTransform {
        scaledBy(x: scale, y: scale)
    }
    
    @inlinable public func scaledBy(_ scale: CGSize) -> CGAffineTransform {
        scaledBy(x: scale.width, y: scale.height)
    }
}

extension CGAffineTransform {
    @inlinable public mutating func translateBy(x: CGFloat = 0, y: CGFloat = 0) {
        self = translatedBy(x: x, y: y)
    }
    
    @inlinable public mutating func translateBy(_ point: CGPoint) {
        self = translatedBy(point)
    }
    
    @inlinable public mutating func scaleBy(x: CGFloat = 1, y: CGFloat = 1) {
        self = scaledBy(x: x, y: y)
    }
    
    @inlinable public mutating func scaleBy(_ scale: CGFloat) {
        self = scaledBy(scale)
    }
    
    @inlinable public mutating func scaleBy(_ scale: CGSize) {
        self = scaledBy(scale)
    }
    
    @inlinable public mutating func rotateBy(_ angle: CGFloat) {
        self = rotated(by: angle)
    }
    
    @inlinable public mutating func invert() {
        self = inverted()
    }
    
    @inlinable public mutating func concatenate(_ t2: CGAffineTransform) {
        self = concatenating(t2)
    }
}
