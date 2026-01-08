import Foundation

extension FloatingPoint {
    public func rounded(scale: Self, rule: FloatingPointRoundingRule) -> Self {
        (self * scale).rounded(rule) / scale
    }
}

extension CGFloat {
    // MARK: - CGFloat CGPoint operations
    
    @inlinable public static func + (left: CGFloat, right: CGPoint) -> CGPoint {
        CGPoint(x: left + right.x, y: left + right.y)
    }

    @inlinable public static func - (left: CGFloat, right: CGPoint) -> CGPoint {
        CGPoint(x: left - right.x, y: left - right.y)
    }

    @inlinable public static func * (left: CGFloat, right: CGPoint) -> CGPoint {
        CGPoint(x: left * right.x, y: left * right.y)
    }

    @inlinable public static func / (left: CGFloat, right: CGPoint) -> CGPoint {
        CGPoint(x: left / right.x, y: left / right.y)
    }
    
    // MARK: - CGFloat CGSize operations
    
    @inlinable public static func + (left: CGFloat, right: CGSize) -> CGSize {
        CGSize(width: left + right.width, height: left + right.height)
    }

    @inlinable public static func - (left: CGFloat, right: CGSize) -> CGSize {
        CGSize(width: left - right.width, height: left - right.height)
    }

    @inlinable public static func * (left: CGFloat, right: CGSize) -> CGSize {
        CGSize(width: left * right.width, height: left * right.height)
    }

    @inlinable public static func / (left: CGFloat, right: CGSize) -> CGSize {
        CGSize(width: left / right.width, height: left / right.height)
    }
}
