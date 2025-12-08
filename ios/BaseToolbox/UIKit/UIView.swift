
#if canImport(UIKit)

import UIKit

extension UIView {
    private struct AssociateKey {
        static var borderColor: Void?
        static var shadowColor: Void?
        static var hitTestSlop: Void?
        static var hasRegisteredForTraitCollectionChange: Void?
    }

    @objc open var cornerRadius: CGFloat {
        get { layer.cornerRadius }
        set { layer.cornerRadius = newValue }
    }

    @objc open var cornerCurve: CALayerCornerCurve {
        get { layer.cornerCurve }
        set { layer.cornerCurve = newValue }
    }

    @objc open var maskedCorners: CACornerMask {
        get { layer.maskedCorners }
        set { layer.maskedCorners = newValue }
    }

    @objc open var zPosition: CGFloat {
        get { layer.zPosition }
        set { layer.zPosition = newValue }
    }

    @objc open var borderWidth: CGFloat {
        get { layer.borderWidth }
        set { layer.borderWidth = newValue }
    }

    @objc open var shadowOpacity: CGFloat {
        get { CGFloat(layer.shadowOpacity) }
        set { layer.shadowOpacity = Float(newValue) }
    }

    @objc open var shadowRadius: CGFloat {
        get { layer.shadowRadius }
        set { layer.shadowRadius = newValue }
    }

    @objc open var shadowOffset: CGSize {
        get { layer.shadowOffset }
        set { layer.shadowOffset = newValue }
    }

    @objc open var shadowPath: UIBezierPath? {
        get { layer.shadowPath.map { UIBezierPath(cgPath: $0) } }
        set { layer.shadowPath = newValue?.cgPath }
    }

    @objc open var hitTestSlop: UIEdgeInsets {
        get {
            (objc_getAssociatedObject(self, &AssociateKey.hitTestSlop) as? NSValue)?.uiEdgeInsetsValue ?? .zero
        }
        set {
            _ = UIView.swizzlePointInside
            objc_setAssociatedObject(self, &AssociateKey.hitTestSlop, NSValue(uiEdgeInsets: newValue), .OBJC_ASSOCIATION_RETAIN)
        }
    }

    @objc open var borderColor: UIColor? {
        get {
            objc_getAssociatedObject(self, &AssociateKey.borderColor) as? UIColor
        }
        set {
            objc_setAssociatedObject(self, &AssociateKey.borderColor, newValue, .OBJC_ASSOCIATION_RETAIN)
            layer.borderColor = borderColor?.resolvedColor(with: traitCollection).cgColor
            if #available(iOS 17.0, *) {
                registerTraitCollectionChangeIfNeeded()
            } else {
                _ = UIView.swizzleTraitCollection
            }
        }
    }

    @objc open var shadowColor: UIColor? {
        get {
            objc_getAssociatedObject(self, &AssociateKey.shadowColor) as? UIColor
        }
        set {
            objc_setAssociatedObject(self, &AssociateKey.shadowColor, newValue, .OBJC_ASSOCIATION_RETAIN)
            layer.shadowColor = shadowColor?.resolvedColor(with: traitCollection).cgColor
            if #available(iOS 17.0, *) {
                registerTraitCollectionChangeIfNeeded()
            } else {
                _ = UIView.swizzleTraitCollection
            }
        }
    }

    @objc open var frameWithoutTransform: CGRect {
        get {
            CGRect(center: center, size: bounds.size)
        }
        set {
            bounds.size = newValue.size
            center = newValue.offsetBy(
                dx: bounds.width * (layer.anchorPoint.x - 0.5),
                dy: bounds.height * (layer.anchorPoint.y - 0.5)
            ).center
        }
    }

    @objc open var firstResponder: UIView? {
        if isFirstResponder {
            return self
        }
        for subview in subviews {
            if let firstResponder = subview.firstResponder {
                return firstResponder
            }
        }
        return nil
    }

    @objc open class var isInAnimationBlock: Bool {
        UIView.perform(NSSelectorFromString("_isInAnimationBlock")) != nil
    }

    private static let swizzlePointInside: Void = {
        guard let originalMethod = class_getInstanceMethod(UIView.self, #selector(point(inside:with:))),
              let swizzledMethod = class_getInstanceMethod(UIView.self, #selector(swizzled_point(inside:with:)))
        else { return }
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }()

    private static let swizzleTraitCollection: Void = {
        guard let originalMethod = class_getInstanceMethod(UIView.self, #selector(traitCollectionDidChange(_:))),
              let swizzledMethod = class_getInstanceMethod(UIView.self, #selector(swizzled_traitCollectionDidChange(_:)))
        else { return }
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }()

    @objc func swizzled_traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        swizzled_traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateColorBasedOnTraitCollection()
        }
    }

    @objc func swizzled_point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        bounds.inset(by: hitTestSlop).contains(point)
    }

    private var hasRegisteredForTraitCollectionChange: Bool {
        get {
            objc_getAssociatedObject(self, &AssociateKey.hasRegisteredForTraitCollectionChange) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &AssociateKey.hasRegisteredForTraitCollectionChange, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }

    private func registerTraitCollectionChangeIfNeeded() {
        if #available(iOS 17.0, *), !hasRegisteredForTraitCollectionChange {
            hasRegisteredForTraitCollectionChange = true
            registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (view: Self, previousTraitCollection) in
                if view.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                    view.updateColorBasedOnTraitCollection()
                }
            }
        }
    }

    private func updateColorBasedOnTraitCollection() {
        if let borderColor {
            layer.borderColor = borderColor.resolvedColor(with: traitCollection).cgColor
        }
        if let shadowColor {
            layer.shadowColor = shadowColor.resolvedColor(with: traitCollection).cgColor
        }
    }
}

extension UIView {
    @objc open var parentViewController: UIViewController? {
        var responder: UIResponder? = self
        while responder is UIView {
            responder = responder!.next
        }
        return responder as? UIViewController
    }

    @objc open var presentedViewController: UIViewController? {
        parentViewController?.presentedViewController
    }

    @objc open var presentingViewController: UIViewController? {
        parentViewController?.presentingViewController
    }
}

extension UIView {
    /// Create image snapshot of view.
    ///
    /// - Parameters:
    ///   - rect: The coordinates (in the view's own coordinate space) to be captured. If omitted, the entire `bounds` will be captured.
    ///   - afterScreenUpdates: A Boolean value that indicates whether the snapshot should be rendered after recent changes have been incorporated. Specify the value false if you want to render a snapshot in the view hierarchy’s current state, which might not include recent changes. Defaults to `true`.
    ///
    /// - Returns: The `UIImage` snapshot.

    public func snapshot(of rect: CGRect? = nil, afterScreenUpdates: Bool = true) -> UIImage {
        UIGraphicsImageRenderer(bounds: rect ?? bounds).image { _ in
            drawHierarchy(in: bounds, afterScreenUpdates: afterScreenUpdates)
        }
    }
}

extension UIView {
    @available(*, deprecated, renamed: "flattenedSubviews")
    public var flattendSubviews: [UIView] {
        subviews + subviews.flatMap { $0.flattenedSubviews }
    }

    public var flattenedSubviews: [UIView] {
        subviews + subviews.flatMap { $0.flattenedSubviews }
    }

    public func superviewMatching<T: UIView>(type: T.Type) -> T? {
        superviewPassing {
            $0 is T
        } as? T
    }

    public func subviewMatching<T: UIView>(type: T.Type) -> T? {
        subviewPassing {
            $0 is T
        } as? T
    }

    public func viewMatching<T: UIView>(type: T.Type) -> T? {
        viewPassing {
            $0 is T
        } as? T
    }

    public func viewPassing(test: (UIView) -> Bool) -> UIView? {
        if test(self) {
            return self
        } else if let superview = superviewPassing(test: test) {
            return superview
        } else if let subview = subviewPassing(test: test) {
            return subview
        }
        return nil
    }

    public func superviewPassing(test: (UIView) -> Bool) -> UIView? {
        var superview = superview
        while let current = superview {
            if test(current) {
                return current
            }
            superview = current.superview
        }
        return nil
    }

    public func subviewPassing(test: (UIView) -> Bool) -> UIView? {
        for subview in subviews {
            if test(subview) {
                return subview
            }
            if let result = subview.subviewPassing(test: test) {
                return result
            }
        }
        return nil
    }
}

extension UIView {
    @objc open func present(_ viewController: UIViewController, completion: (() -> Void)? = nil) {
        if let customPresentationMethod = BaseToolbox.customPresentationMethod {
            customPresentationMethod(self, viewController, completion)
        } else {
            parentViewController?.present(viewController, animated: true, completion: completion)
        }
    }

    @objc open func push(_ viewController: UIViewController) {
        if let customPushMethod = BaseToolbox.customPushMethod {
            customPushMethod(self, viewController)
        } else {
            parentViewController?.navigationController?.pushViewController(viewController, animated: true)
        }
    }

    @objc open func dismiss(completion: (() -> Void)? = nil) {
        if let customDismissMethod = BaseToolbox.customDismissMethod {
            customDismissMethod(self, completion)
        } else {
            guard let viewController = parentViewController else {
                return
            }
            if let navVC = viewController.navigationController, navVC.viewControllers.count > 1 {
                navVC.popViewController(animated: true)
                completion?()
            } else {
                viewController.dismiss(animated: true, completion: completion)
            }
        }
    }

    @objc open func dismissModal(completion: (() -> Void)? = nil) {
        guard let viewController = parentViewController else {
            return
        }
        viewController.dismiss(animated: true, completion: completion)
    }
}

extension UIView {
    @available(*, deprecated, renamed: "superviewMatching(type:)")
    public func superview<T: UIView>(matchingType _: T.Type) -> T? {
        var current: UIView? = self
        while let next = current?.superview {
            if let next = next as? T {
                return next
            }
            current = next
        }
        return nil
    }

    @available(*, deprecated, message: "Please use `subviewPassing(test:)`, `viewPassing(test:)`, `subviewMatching(type:)`, or `viewMatching(type:)` instead")
    public func findSubview<ViewType: UIView>(checker: ((ViewType) -> Bool)? = nil) -> ViewType? {
        for subview in [self] + flattenedSubviews.reversed() {
            if let subview = subview as? ViewType, checker?(subview) != false {
                return subview
            }
        }
        return nil
    }

    @available(*, deprecated, message: "Please use `subviewPassing(test:)` or `viewPassing(test:)` instead")
    public func contains(view: UIView) -> Bool {
        if view == self {
            return true
        }
        return subviews.contains(where: { $0.contains(view: view) })
    }

    @available(*, deprecated, renamed: "superviewMatching(type:)")
    public func closestViewMatchingType<ViewType: UIView>(_: ViewType.Type) -> ViewType? {
        closestViewPassingTest {
            $0 is ViewType
        } as? ViewType
    }

    @available(*, deprecated, renamed: "superviewPassing(test:)")
    public func closestViewPassingTest(_ test: (UIView) -> Bool) -> UIView? {
        var current: UIView? = self.superview
        while current != nil {
            if test(current!) {
                return current
            }
            current = current?.superview
        }
        return nil
    }
}

#endif
