//
//  UIView+Extensions.swift
//  
//
//  Created by Luke Zhao on 10/7/23.
//

import Foundation
import UIKit

func setupCustomPresentation() {
    BaseToolbox.customDismissMethod = { (view, completion) in
        if let navView = view.navigationView, navView.views.count > 1 {
            navView.popView(animated: true)
            completion?()
        } else if let navVC = view.navigationController, navVC.views.count > 1 {
            navVC.popView(animated: true)
            completion?()
        } else if let navVC = view.parentViewController?.navigationController, navVC.viewControllers.count > 1 {
            navVC.popViewController(animated: true)
            completion?()
        } else {
            view.parentViewController?.dismiss(animated: true, completion: completion)
        }
    }
}

extension UIView {
    private static var lockedSafeAreaInsets: [UIView: UIEdgeInsets] = [:]

    private static let swizzleSafeAreaInsets: Void = {
        guard let originalMethod = class_getInstanceMethod(UIView.self, #selector(getter: safeAreaInsets)),
              let swizzledMethod = class_getInstanceMethod(UIView.self, #selector(getter: swizzled_safeAreaInsets))
        else { return }
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }()

    public var lockedSafeAreaInsets: UIEdgeInsets? {
        get {
            Self.lockedSafeAreaInsets[self]
        }
        set {
            _ = UIView.swizzleSafeAreaInsets
            Self.lockedSafeAreaInsets[self] = newValue
        }
    }

    @objc var swizzled_safeAreaInsets: UIEdgeInsets {
        if !Self.lockedSafeAreaInsets.isEmpty {
            if let insets = Self.lockedSafeAreaInsets[self] {
                return insets
            } else if
                let lockedInsetSuperview = superviewPassing(test: { Self.lockedSafeAreaInsets[$0] != nil }),
                let superviewInset = Self.lockedSafeAreaInsets[lockedInsetSuperview] {
                let frame = lockedInsetSuperview.convert(bounds, from: self)
                let superviewBounds = lockedInsetSuperview.bounds.inset(by: superviewInset)
                return UIEdgeInsets(top: max(0, superviewBounds.minY - frame.minY),
                                    left: max(0, superviewBounds.minX - frame.minX),
                                    bottom: max(0, frame.maxY - superviewBounds.maxY),
                                    right: max(0, frame.maxX - superviewBounds.maxX))
            }
        }
        return self.swizzled_safeAreaInsets
    }
}

extension UIView {
    var flattendSuperviews: [UIView] {
        if let superview {
            return [superview] + superview.flattendSuperviews
        } else {
            return []
        }
    }
}

extension UIView {
    public var translationX: CGFloat {
        get {
            value(forKeyPath: "layer.transform.translation.x") as? CGFloat ?? 0
        }
        set {
            setValue(newValue, forKeyPath: "layer.transform.translation.x")
        }
    }
    public var translationY: CGFloat {
        get {
            value(forKeyPath: "layer.transform.translation.y") as? CGFloat ?? 0
        }
        set {
            setValue(newValue, forKeyPath: "layer.transform.translation.y")
        }
    }
    public var translation: CGPoint {
        get {
            value(forKeyPath: "layer.transform.translation") as? CGPoint ?? .zero
        }
        set {
            setValue(newValue, forKeyPath: "layer.transform.translation")
        }
    }
    public var rotation: CGFloat {
        get {
            value(forKeyPath: "layer.transform.rotation") as? CGFloat ?? 0
        }
        set {
            setValue(newValue, forKeyPath: "layer.transform.rotation")
        }
    }
    public var scale: CGFloat {
        get {
            value(forKeyPath: "layer.transform.scale") as? CGFloat ?? 0
        }
        set {
            setValue(newValue, forKeyPath: "layer.transform.scale")
        }
    }
}
