import CoreGraphics

extension CGPoint {
    @inlinable public var transposed: CGPoint {
        CGPoint(x: y, y: x)
    }
    
    @inlinable public func translate(_ dx: CGFloat, dy: CGFloat) -> CGPoint {
        CGPoint(x: x + dx, y: y + dy)
    }
    
    @inlinable public func transform(_ trans: CGAffineTransform) -> CGPoint {
        applying(trans)
    }
    
    @inlinable public func distance(_ point: CGPoint) -> CGFloat {
        sqrt(pow(x - point.x, 2) + pow(y - point.y, 2))
    }
    
    @inlinable public func midPoint(from: CGPoint) -> CGPoint {
        CGPoint(x: (x + from.x) / 2, y: (y + from.y) / 2)
    }
    
    @inlinable public func clamp(to rect: CGRect) -> CGPoint {
        CGPoint(x: x.clamp(rect.minX, rect.maxX), y: y.clamp(rect.minY, rect.maxY))
    }

    @inlinable public func rounded(scale: CGFloat, rule: FloatingPointRoundingRule) -> Self {
        (self * scale).rounded(rule) / scale
    }

    @inlinable public func rounded(_ rule: FloatingPointRoundingRule) -> Self {
        CGPoint(x: x.rounded(rule), y: y.rounded(rule))
    }
    
    @inlinable public init(_ cgSize: CGSize) {
        self.init(x: cgSize.width, y: cgSize.height)
    }
    
    // MARK: - CGPoint operations

    @inlinable public static func + (left: CGPoint, right: CGPoint) -> CGPoint {
        CGPoint(x: left.x + right.x, y: left.y + right.y)
    }

    @inlinable public static func - (left: CGPoint, right: CGPoint) -> CGPoint {
        CGPoint(x: left.x - right.x, y: left.y - right.y)
    }

    @inlinable public static func * (left: CGPoint, right: CGPoint) -> CGPoint {
        CGPoint(x: left.x * right.x, y: left.y * right.y)
    }

    @inlinable public static func / (left: CGPoint, right: CGPoint) -> CGPoint {
        CGPoint(x: left.x / right.x, y: left.y / right.y)
    }

    @inlinable public static prefix func - (point: CGPoint) -> CGPoint {
        CGPoint.zero - point
    }

    @inlinable public static func += (left: inout CGPoint, right: CGPoint) {
        left.x += right.x
        left.y += right.y
    }

    @inlinable public static func -= (left: inout CGPoint, right: CGPoint) {
        left.x -= right.x
        left.y -= right.y
    }

    @inlinable public static func *= (left: inout CGPoint, right: CGPoint) {
        left.x *= right.x
        left.y *= right.y
    }

    @inlinable public static func /= (left: inout CGPoint, right: CGPoint) {
        left.x /= right.x
        left.y /= right.y
    }

    // MARK: - CGPoint CGFloat operations

    @inlinable public static func + (left: CGPoint, right: CGFloat) -> CGPoint {
        CGPoint(x: left.x + right, y: left.y + right)
    }

    @inlinable public static func - (left: CGPoint, right: CGFloat) -> CGPoint {
        CGPoint(x: left.x - right, y: left.y - right)
    }

    @inlinable public static func * (left: CGPoint, right: CGFloat) -> CGPoint {
        CGPoint(x: left.x * right, y: left.y * right)
    }

    @inlinable public static func / (left: CGPoint, right: CGFloat) -> CGPoint {
        CGPoint(x: left.x / right, y: left.y / right)
    }

    @inlinable public static func += (left: inout CGPoint, right: CGFloat) {
        left.x += right
        left.y += right
    }

    @inlinable public static func -= (left: inout CGPoint, right: CGFloat) {
        left.x -= right
        left.y -= right
    }

    @inlinable public static func *= (left: inout CGPoint, right: CGFloat) {
        left.x *= right
        left.y *= right
    }

    @inlinable public static func /= (left: inout CGPoint, right: CGFloat) {
        left.x /= right
        left.y /= right
    }

    // MARK: - CGPoint CGSize operations

    @inlinable public static func + (left: CGPoint, right: CGSize) -> CGPoint {
        left + CGPoint(right)
    }

    @inlinable public static func - (left: CGPoint, right: CGSize) -> CGPoint {
        left - CGPoint(right)
    }

    @inlinable public static func * (left: CGPoint, right: CGSize) -> CGPoint {
        left * CGPoint(right)
    }

    @inlinable public static func / (left: CGPoint, right: CGSize) -> CGPoint {
        left / CGPoint(right)
    }

    @inlinable public static func += (left: inout CGPoint, right: CGSize) {
        left += CGPoint(right)
    }

    @inlinable public static func -= (left: inout CGPoint, right: CGSize) {
        left -= CGPoint(right)
    }

    @inlinable public static func *= (left: inout CGPoint, right: CGSize) {
        left *= CGPoint(right)
    }

    @inlinable public static func /= (left: inout CGPoint, right: CGSize) {
        left /= CGPoint(right)
    }
}

@inlinable public func abs(_ point: CGPoint) -> CGPoint {
    CGPoint(x: abs(point.x), y: abs(point.y))
}

@inlinable public func min(_ left: CGPoint, _ right: CGPoint) -> CGPoint {
    CGPoint(x: min(left.x, right.x), y: min(left.y, right.y))
}

@inlinable public func max(_ left: CGPoint, _ right: CGPoint) -> CGPoint {
    CGPoint(x: max(left.x, right.x), y: max(left.y, right.y))
}
