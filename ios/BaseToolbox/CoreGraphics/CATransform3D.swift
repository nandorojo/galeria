import QuartzCore

extension CATransform3D {
    public static let identity = CATransform3DIdentity

    @inlinable public var isIdentity: Bool {
        CATransform3DIsIdentity(self)
    }
    
    @inlinable public var isAffine: Bool {
        CATransform3DIsAffine(self)
    }
    
    @inlinable public var affineTransform: CGAffineTransform {
        CATransform3DGetAffineTransform(self)
    }
    
    @inlinable public init(affineTransform: CGAffineTransform) {
        self = CATransform3DMakeAffineTransform(affineTransform)
    }
}

extension CATransform3D: Equatable {
    @inlinable public static func == (lhs: CATransform3D, rhs: CATransform3D) -> Bool {
        CATransform3DEqualToTransform(lhs, rhs)
    }
}

extension CATransform3D {
    @inlinable public func translatedBy(x: CGFloat = 0, y: CGFloat = 0, z: CGFloat = 0) -> CATransform3D {
        CATransform3DTranslate(self, x, y, z)
    }
    
    @inlinable public func translatedBy(_ point: CGPoint) -> CATransform3D {
        CATransform3DTranslate(self, point.x, point.y, 0)
    }
    
    @inlinable public func scaledBy(x: CGFloat = 1, y: CGFloat = 1, z: CGFloat = 1) -> CATransform3D {
        CATransform3DScale(self, x, y, z)
    }
    
    @inlinable public func scaledBy(_ scale: CGFloat) -> CATransform3D {
        CATransform3DScale(self, scale, scale, 1)
    }
    
    @inlinable public func scaledBy(_ scale: CGSize) -> CATransform3D {
        CATransform3DScale(self, scale.width, scale.height, 1)
    }
    
    @inlinable public func rotatedBy(angle: CGFloat, x: CGFloat, y: CGFloat, z: CGFloat) -> CATransform3D {
        CATransform3DRotate(self, angle, x, y, z)
    }
    
    @inlinable public func rotatedBy(x: CGFloat) -> CATransform3D {
        CATransform3DRotate(self, x, 1, 0, 0)
    }
    
    @inlinable public func rotatedBy(y: CGFloat) -> CATransform3D {
        CATransform3DRotate(self, y, 0, 1, 0)
    }
    
    @inlinable public func rotatedBy(z: CGFloat) -> CATransform3D {
        CATransform3DRotate(self, z, 0, 0, 1)
    }
    
    @inlinable public func rotatedBy(_ angle: CGFloat) -> CATransform3D {
        CATransform3DRotate(self, angle, 0, 0, 1)
    }
    
    @inlinable public func withPerspective(m34: CGFloat) -> CATransform3D {
        var trans = self
        trans.m34 = m34
        return trans
    }
    
    @inlinable public func inverted() -> CATransform3D {
        CATransform3DInvert(self)
    }
    
    @inlinable public func concatenating(_ t2: CATransform3D) -> CATransform3D {
        CATransform3DConcat(self, t2)
    }
}

extension CATransform3D {
    @inlinable public mutating func translateBy(x: CGFloat = 0, y: CGFloat = 0, z: CGFloat = 0) {
        self = translatedBy(x: x, y: y, z: z)
    }
    
    @inlinable public mutating func translateBy(_ point: CGPoint) {
        self = translatedBy(point)
    }
    
    @inlinable public mutating func scaleBy(x: CGFloat = 1, y: CGFloat = 1, z: CGFloat = 1) {
        self = scaledBy(x: x, y: y, z: z)
    }
    
    @inlinable public mutating func scaleBy(_ scale: CGFloat) {
        self = scaledBy(scale)
    }
    
    @inlinable public mutating func scaleBy(_ scale: CGSize) {
        self = scaledBy(scale)
    }
    
    @inlinable public mutating func rotateBy(angle: CGFloat, x: CGFloat, y: CGFloat, z: CGFloat) {
        self = rotatedBy(angle: angle, x: x, y: y, z: z)
    }
    
    @inlinable public mutating func rotateBy(x: CGFloat) {
        self = rotatedBy(x: x)
    }
    
    @inlinable public mutating func rotateBy(y: CGFloat) {
        self = rotatedBy(y: y)
    }
    
    @inlinable public mutating func rotateBy(z: CGFloat) {
        self = rotatedBy(z: z)
    }
    
    @inlinable public mutating func rotateBy(_ angle: CGFloat) {
        self = rotatedBy(angle)
    }
    
    @inlinable public mutating func perspective(m34: CGFloat) {
        self.m34 = m34
    }
    
    @inlinable public mutating func invert() {
        self = inverted()
    }
    
    @inlinable public mutating func concatenate(_ t2: CATransform3D) {
        self = concatenating(t2)
    }
}
