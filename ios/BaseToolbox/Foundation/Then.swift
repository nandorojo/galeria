import Foundation


// Credit: https://github.com/devxoul/Then
// Copying it here to make it easier to use, and fix project warnings
public protocol Then {}

extension Then where Self: Any {
    
    /// Makes it available to set properties with closures just after initializing and copying the value types.
    ///
    ///     let frame = CGRect().with {
    ///       $0.origin.x = 10
    ///       $0.size.width = 100
    ///     }
    @inlinable
    public func with(_ block: (inout Self) throws -> Void) rethrows -> Self {
        var copy = self
        try block(&copy)
        return copy
    }
    
    @inlinable
    public func with<Value>(_ keyPath: WritableKeyPath<Self, Value>, value: Value) -> Self {
        var newItem = self
        newItem[keyPath: keyPath] = value
        return newItem
    }
    
    /// Makes it available to execute something with closures.
    ///
    ///     UserDefaults.standard.do {
    ///       $0.set("devxoul", forKey: "username")
    ///       $0.set("devxoul@gmail.com", forKey: "email")
    ///       $0.synchronize()
    ///     }
    @inlinable
    public func `do`(_ block: (Self) throws -> Void) rethrows {
        try block(self)
    }
    
}

extension Then where Self: AnyObject {
    
    /// Makes it available to set properties with closures just after initializing.
    ///
    ///     let label = UILabel().then {
    ///       $0.textAlignment = .center
    ///       $0.textColor = UIColor.black
    ///       $0.text = "Hello, World!"
    ///     }
    @inlinable
    public func then(_ block: (Self) throws -> Void) rethrows -> Self {
        try block(self)
        return self
    }
    
}

extension NSObject: Then {}

extension Array: Then {}
extension Dictionary: Then {}
extension Set: Then {}

extension CGPoint: Then {}
extension CGRect: Then {}
extension CGSize: Then {}
extension CGVector: Then {}

#if canImport(UIKit)

import UIKit
extension UIEdgeInsets: Then {}
extension UIOffset: Then {}
extension UIRectEdge: Then {}

#endif
