
import CoreGraphics

extension CGRect {
    @inlinable public var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
    
    @inlinable public var bounds: CGRect {
        CGRect(origin: .zero, size: size)
    }
    
    @inlinable public var transposed: CGRect {
        CGRect(origin: origin.transposed, size: size.transposed)
    }
    
    /// force positive width and height
    /// (0, 0, -100, -100) -> (-100, -100, 100, 100)
    @inlinable public var normalized: CGRect {
        CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
    
    @inlinable public var topLeft: CGPoint {
        CGPoint(x: minX, y: minY)
    }

    @inlinable public var topCenter: CGPoint {
        CGPoint(x: midX, y: minY)
    }
    
    @inlinable public var topRight: CGPoint {
        CGPoint(x: maxX, y: minY)
    }

    @inlinable public var leftCenter: CGPoint {
        CGPoint(x: minX, y: midY)
    }
    
    @inlinable public var bottomLeft: CGPoint {
        CGPoint(x: minX, y: maxY)
    }

    @inlinable public var bottomCenter: CGPoint {
        CGPoint(x: midX, y: maxY)
    }
    
    @inlinable public var bottomRight: CGPoint {
        CGPoint(x: maxX, y: maxY)
    }

    @inlinable public var rightCenter: CGPoint {
        CGPoint(x: maxX, y: midY)
    }
    
    @inlinable public init(center: CGPoint, size: CGSize) {
        self.init(origin: center - size / 2, size: size)
    }

    @inlinable public func rounded(scale: CGFloat, rule: FloatingPointRoundingRule) -> Self {
        (self * scale).rounded(rule) / scale
    }

    @inlinable public func rounded(_ rule: FloatingPointRoundingRule) -> Self {
        CGRect(origin: origin.rounded(rule), size: size.rounded(rule))
    }

    // MARK: - CGRect operations

    @inlinable public static func + (lhs: CGRect, rhs: CGRect) -> CGRect {
        CGRect(origin: lhs.origin + rhs.origin, size: lhs.size + rhs.size)
    }

    @inlinable public static func - (lhs: CGRect, rhs: CGRect) -> CGRect {
        CGRect(origin: lhs.origin - rhs.origin, size: lhs.size - rhs.size)
    }

    @inlinable public static func * (lhs: CGRect, rhs: CGRect) -> CGRect {
        CGRect(origin: lhs.origin * rhs.origin, size: lhs.size * rhs.size)
    }

    @inlinable public static func / (lhs: CGRect, rhs: CGRect) -> CGRect {
        CGRect(origin: lhs.origin / rhs.origin, size: lhs.size / rhs.size)
    }

    @inlinable public static prefix func - (size: CGRect) -> CGRect {
        CGRect.zero - size
    }

    @inlinable public static func += (left: inout CGRect, right: CGRect) {
        left.origin += right.origin
        left.size += right.size
    }

    @inlinable public static func -= (left: inout CGRect, right: CGRect) {
        left.origin -= right.origin
        left.size -= right.size
    }

    @inlinable public static func *= (left: inout CGRect, right: CGRect) {
        left.origin *= right.origin
        left.size *= right.size
    }

    @inlinable public static func /= (left: inout CGRect, right: CGRect) {
        left.origin /= right.origin
        left.size /= right.size
    }

    // MARK: - CGRect CGFloat operations

    @inlinable public static func + (left: CGRect, right: CGFloat) -> CGRect {
        CGRect(origin: left.origin + right, size: left.size + right)
    }

    @inlinable public static func - (left: CGRect, right: CGFloat) -> CGRect {
        CGRect(origin: left.origin - right, size: left.size - right)
    }

    @inlinable public static func * (left: CGRect, right: CGFloat) -> CGRect {
        CGRect(origin: left.origin * right, size: left.size * right)
    }

    @inlinable public static func / (left: CGRect, right: CGFloat) -> CGRect {
        CGRect(origin: left.origin / right, size: left.size / right)
    }

    @inlinable public static func += (left: inout CGRect, right: CGFloat) {
        left.origin += right
        left.size += right
    }

    @inlinable public static func -= (left: inout CGRect, right: CGFloat) {
        left.origin -= right
        left.size -= right
    }

    @inlinable public static func *= (left: inout CGRect, right: CGFloat) {
        left.origin *= right
        left.size *= right
    }

    @inlinable public static func /= (left: inout CGRect, right: CGFloat) {
        left.origin /= right
        left.size /= right
    }

    // MARK: - CGRect CGPoint operations

    @inlinable public static func + (left: CGRect, right: CGPoint) -> CGRect {
        CGRect(origin: left.origin + right, size: left.size)
    }

    @inlinable public static func - (left: CGRect, right: CGPoint) -> CGRect {
        CGRect(origin: left.origin - right, size: left.size)
    }

    @inlinable public static func += (left: inout CGRect, right: CGPoint) {
        left.origin += right
    }

    @inlinable public static func -= (left: inout CGRect, right: CGPoint) {
        left.origin -= right
    }

    // MARK: - CGRect CGSize operations

    @inlinable public static func + (left: CGRect, right: CGSize) -> CGRect {
        CGRect(origin: left.origin, size: left.size + right)
    }

    @inlinable public static func - (left: CGRect, right: CGSize) -> CGRect {
        CGRect(origin: left.origin, size: left.size - right)
    }

    @inlinable public static func += (left: inout CGRect, right: CGSize) {
        left.size += right
    }

    @inlinable public static func -= (left: inout CGRect, right: CGSize) {
        left.size -= right
    }
}

#if canImport(UIKit)

import UIKit

extension CGRect {
    public func closestCorner(point: CGPoint) -> UIRectCorner {
        let corners: [(point: CGPoint, corner: UIRectCorner)] = [
            (topLeft, .topLeft),
            (topRight, .topRight),
            (bottomLeft, .bottomLeft),
            (bottomRight, .bottomRight),
        ]
        return corners.sorted { a, b in
            point.distance(a.point) < point.distance(b.point)
        }.first!.corner
    }

    public mutating func offset(corner: UIRectCorner, offset: CGPoint, minimumSize: CGSize, maximumSize: CGSize) {
        switch corner {
        case .topLeft:
            let clamped = CGPoint(x: offset.x.clamp(-origin.x, size.width - minimumSize.width),
                                  y: offset.y.clamp(-origin.y, size.height - minimumSize.height))
            origin = CGPoint(x: origin.x + clamped.x, y: origin.y + clamped.y)
            size = CGSize(width: size.width - clamped.x, height: size.height - clamped.y)
        case .topRight:
            let clamped = CGPoint(x: offset.x.clamp(-(size.width - minimumSize.width), maximumSize.width - origin.x - size.width),
                                  y: offset.y.clamp(-origin.y, size.height - minimumSize.height))
            origin = CGPoint(x: origin.x, y: origin.y + clamped.y)
            size = CGSize(width: size.width + clamped.x, height: size.height - clamped.y)
        case .bottomLeft:
            let clamped = CGPoint(x: offset.x.clamp(-origin.x, size.width - minimumSize.width),
                                  y: offset.y.clamp(-(size.height - minimumSize.height), maximumSize.height - origin.y - size.height))
            origin = CGPoint(x: origin.x + clamped.x, y: origin.y)
            size = CGSize(width: size.width - clamped.x, height: size.height + clamped.y)
        case .bottomRight:
            let clamped = CGPoint(x: offset.x.clamp(-(size.width - minimumSize.width), maximumSize.width - origin.x - size.width),
                                  y: offset.y.clamp(-(size.height - minimumSize.height), maximumSize.height - origin.y - size.height))
            origin = CGPoint(x: origin.x, y: origin.y)
            size = CGSize(width: size.width + clamped.x, height: size.height + clamped.y)
        default:
            break
        }
    }
}

#endif
