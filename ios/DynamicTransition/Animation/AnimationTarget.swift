//
//  AnimationTarget.swift
//
//
//  Created by Luke Zhao on 11/13/23.
//

import UIKit
import Motion

internal struct AnimationTarget<View: UIView, Value: SIMDRepresentable>: Hashable {
    public let id: ObjectIdentifier
    public weak var view: View?
    public let keyPath: ReferenceWritableKeyPath<View, Value>

    public init(view: View, keyPath: ReferenceWritableKeyPath<View, Value>) {
        self.view = view
        self.keyPath = keyPath
        self.id = ObjectIdentifier(view)
    }

    public var value: Value {
        get {
            view?[keyPath: keyPath] ?? .zero
        }
        nonmutating set {
            view?[keyPath: keyPath] = newValue
        }
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(keyPath)
    }

    public static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id && lhs.keyPath == rhs.keyPath
    }
}
