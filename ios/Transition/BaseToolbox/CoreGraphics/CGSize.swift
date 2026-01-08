
import CoreGraphics

extension CGSize {
    @inlinable public var transposed: CGSize {
        CGSize(width: height, height: width)
    }
    
    @inlinable public func transform(_ trans: CGAffineTransform) -> CGSize {
        applying(trans)
    }
    
    @inlinable public func size(fill: CGSize) -> CGSize {
        self * max(fill.width / width, fill.height / height)
    }
    
    @inlinable public func size(fillIfSmaller fill: CGSize) -> CGSize {
        self * max(1, max(fill.width / width, fill.height / height))
    }
    
    @inlinable public func size(fit: CGSize) -> CGSize {
        self * min(fit.width / width, fit.height / height)
    }
    
    @inlinable public func size(fitIfBigger fit: CGSize) -> CGSize {
        self * min(1, min(fit.width / width, fit.height / height))
    }
    
    @inlinable public func rounded(scale: CGFloat, rule: FloatingPointRoundingRule) -> CGSize {
        (self * scale).rounded(rule) / scale
    }

    @inlinable public func rounded(_ rule: FloatingPointRoundingRule) -> Self {
        CGSize(width: width.rounded(rule), height: height.rounded(rule))
    }
    
    @inlinable public init(_ cgPoint: CGPoint) {
        self.init(width: cgPoint.x, height: cgPoint.y)
    }
    
    // MARK: - CGSize operations

    @inlinable public static func + (left: CGSize, right: CGSize) -> CGSize {
        CGSize(width: left.width + right.width, height: left.height + right.height)
    }

    @inlinable public static func - (left: CGSize, right: CGSize) -> CGSize {
        CGSize(width: left.width - right.width, height: left.height - right.height)
    }

    @inlinable public static func * (left: CGSize, right: CGSize) -> CGSize {
        CGSize(width: left.width * right.width, height: left.height * right.height)
    }

    @inlinable public static func / (left: CGSize, right: CGSize) -> CGSize {
        CGSize(width: left.width / right.width, height: left.height / right.height)
    }

    @inlinable public static prefix func - (size: CGSize) -> CGSize {
        CGSize.zero - size
    }

    @inlinable public static func += (left: inout CGSize, right: CGSize) {
        left.width += right.width
        left.height += right.height
    }

    @inlinable public static func -= (left: inout CGSize, right: CGSize) {
        left.width -= right.width
        left.height -= right.height
    }

    @inlinable public static func *= (left: inout CGSize, right: CGSize) {
        left.width *= right.width
        left.height *= right.height
    }

    @inlinable public static func /= (left: inout CGSize, right: CGSize) {
        left.width /= right.width
        left.height /= right.height
    }

    // MARK: - CGSize CGFloat operations

    @inlinable public static func + (left: CGSize, right: CGFloat) -> CGSize {
        CGSize(width: left.width + right, height: left.height + right)
    }

    @inlinable public static func - (left: CGSize, right: CGFloat) -> CGSize {
        CGSize(width: left.width - right, height: left.height - right)
    }

    @inlinable public static func * (left: CGSize, right: CGFloat) -> CGSize {
        CGSize(width: left.width * right, height: left.height * right)
    }

    @inlinable public static func / (left: CGSize, right: CGFloat) -> CGSize {
        CGSize(width: left.width / right, height: left.height / right)
    }

    @inlinable public static func += (left: inout CGSize, right: CGFloat) {
        left.width += right
        left.height += right
    }

    @inlinable public static func -= (left: inout CGSize, right: CGFloat) {
        left.width -= right
        left.height -= right
    }

    @inlinable public static func *= (left: inout CGSize, right: CGFloat) {
        left.width *= right
        left.height *= right
    }

    @inlinable public static func /= (left: inout CGSize, right: CGFloat) {
        left.width /= right
        left.height /= right
    }

    // MARK: - CGSize CGPoint operations

    @inlinable public static func + (left: CGSize, right: CGPoint) -> CGSize {
        left + CGSize(right)
    }

    @inlinable public static func - (left: CGSize, right: CGPoint) -> CGSize {
        left - CGSize(right)
    }

    @inlinable public static func * (left: CGSize, right: CGPoint) -> CGSize {
        left * CGSize(right)
    }

    @inlinable public static func / (left: CGSize, right: CGPoint) -> CGSize {
        left / CGSize(right)
    }

    @inlinable public static func += (left: inout CGSize, right: CGPoint) {
        left += CGSize(right)
    }

    @inlinable public static func -= (left: inout CGSize, right: CGPoint) {
        left -= CGSize(right)
    }

    @inlinable public static func *= (left: inout CGSize, right: CGPoint) {
        left *= CGSize(right)
    }

    @inlinable public static func /= (left: inout CGSize, right: CGPoint) {
        left /= CGSize(right)
    }
}

#if canImport(UIKit)

import UIKit

extension CGSize {
    public func inset(by insets: UIEdgeInsets) -> CGSize {
        CGSize(width: width - insets.left - insets.right, height: height - insets.top - insets.bottom)
    }
}

#endif

@inlinable public func abs(_ size: CGSize) -> CGSize {
    CGSize(width: abs(size.width), height: abs(size.height))
}

@inlinable public func min(_ left: CGSize, _ right: CGSize) -> CGSize {
    CGSize(width: min(left.width, right.width), height: min(left.height, right.height))
}

@inlinable public func max(_ left: CGSize, _ right: CGSize) -> CGSize {
    CGSize(width: max(left.width, right.width), height: max(left.height, right.height))
}
