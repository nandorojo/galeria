
#if canImport(UIKit)

import UIKit

extension UIEdgeInsets {
    public init(_ all: CGFloat) {
        self.init(top: all, left: all, bottom: all, right: all)
    }
    
    // unfortunately. it has to be all of the combinations
    public init(top: CGFloat) {
        self.init(top: top, left: 0, bottom: 0, right: 0)
    }
    
    public init(top: CGFloat, left: CGFloat) {
        self.init(top: top, left: left, bottom: 0, right: 0)
    }
    public init(top: CGFloat, bottom: CGFloat) {
        self.init(top: top, left: 0, bottom: bottom, right: 0)
    }
    public init(top: CGFloat, right: CGFloat) {
        self.init(top: top, left: 0, bottom: 0, right: right)
    }
    
    public init(top: CGFloat, left: CGFloat, bottom: CGFloat) {
        self.init(top: top, left: left, bottom: bottom, right: 0)
    }
    public init(top: CGFloat, left: CGFloat, right: CGFloat) {
        self.init(top: top, left: left, bottom: 0, right: right)
    }
    
    public init(left: CGFloat) {
        self.init(top: 0, left: left, bottom: 0, right: 0)
    }
    
    public init(left: CGFloat, bottom: CGFloat) {
        self.init(top: 0, left: left, bottom: bottom, right: 0)
    }
    public init(left: CGFloat, right: CGFloat) {
        self.init(top: 0, left: left, bottom: 0, right: right)
    }
    
    public init(left: CGFloat, bottom: CGFloat, right: CGFloat) {
        self.init(top: 0, left: left, bottom: bottom, right: right)
    }
    
    public init(bottom: CGFloat) {
        self.init(top: 0, left: 0, bottom: bottom, right: 0)
    }
    public init(bottom: CGFloat, right: CGFloat) {
        self.init(top: 0, left: 0, bottom: bottom, right: right)
    }
    
    public init(right: CGFloat) {
        self.init(top: 0, left: 0, bottom: 0, right: right)
    }
    
    public init(top: CGFloat, rest: CGFloat) {
        self.init(top: top, left: rest, bottom: rest, right: rest)
    }
    public init(left: CGFloat, rest: CGFloat) {
        self.init(top: rest, left: left, bottom: rest, right: rest)
    }
    public init(bottom: CGFloat, rest: CGFloat) {
        self.init(top: rest, left: rest, bottom: bottom, right: rest)
    }
    public init(right: CGFloat, rest: CGFloat) {
        self.init(top: rest, left: rest, bottom: rest, right: right)
    }
    
    public init(h: CGFloat) {
        self.init(top: 0, left: h, bottom: 0, right: h)
    }
    public init(v: CGFloat) {
        self.init(top: v, left: 0, bottom: v, right: 0)
    }
    public init(v: CGFloat, h: CGFloat) {
        self.init(top: v, left: h, bottom: v, right: h)
    }
    public init(h: CGFloat, v: CGFloat) {
        self.init(top: v, left: h, bottom: v, right: h)
    }
}

public func + (left: UIEdgeInsets, right: UIEdgeInsets) -> UIEdgeInsets {
    UIEdgeInsets(top: left.top + right.top, left: left.left + right.left, bottom: left.bottom + right.bottom, right: left.right + right.right)
}

public func - (left: UIEdgeInsets, right: UIEdgeInsets) -> UIEdgeInsets {
    UIEdgeInsets(top: left.top - right.top, left: left.left - right.left, bottom: left.bottom - right.bottom, right: left.right - right.right)
}

public func * (left: UIEdgeInsets, right: UIEdgeInsets) -> UIEdgeInsets {
    UIEdgeInsets(top: left.top * right.top, left: left.left * right.left, bottom: left.bottom * right.bottom, right: left.right * right.right)
}

public func / (left: UIEdgeInsets, right: UIEdgeInsets) -> UIEdgeInsets {
    UIEdgeInsets(top: left.top / right.top, left: left.left / right.left, bottom: left.bottom / right.bottom, right: left.right / right.right)
}

public prefix func - (inset: UIEdgeInsets) -> UIEdgeInsets {
    UIEdgeInsets(top: -inset.top, left: -inset.left, bottom: -inset.bottom, right: -inset.right)
}

// MARK: - UIEdgeInsets CGFloat operations

public func + (left: UIEdgeInsets, right: CGFloat) -> UIEdgeInsets {
    UIEdgeInsets(top: left.top + right, left: left.left + right, bottom: left.bottom + right, right: left.right + right)
}

public func - (left: UIEdgeInsets, right: CGFloat) -> UIEdgeInsets {
    UIEdgeInsets(top: left.top - right, left: left.left - right, bottom: left.bottom - right, right: left.right - right)
}

public func * (left: UIEdgeInsets, right: CGFloat) -> UIEdgeInsets {
    UIEdgeInsets(top: left.top * right, left: left.left * right, bottom: left.bottom * right, right: left.right * right)
}

public func / (left: UIEdgeInsets, right: CGFloat) -> UIEdgeInsets {
    UIEdgeInsets(top: left.top / right, left: left.left / right, bottom: left.bottom / right, right: left.right / right)
}

#endif
