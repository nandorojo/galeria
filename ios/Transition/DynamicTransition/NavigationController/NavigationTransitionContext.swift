import UIKit

public class NavigationTransitionContext: TransitionContext {
    public let id = UUID()
    public private(set) var container: UIView
    public private(set) var from: UIView
    public private(set) var to: UIView

    public private(set) var isPresenting: Bool
    public private(set) var isInteractive: Bool
    public private(set) var isCompleting: Bool
    public private(set) var isCompleted: Bool

    var onUpdate: (NavigationTransitionContext) -> Void

    init(container: UIView, isPresenting: Bool, from: UIView, to: UIView, isInteractive: Bool, onUpdate: @escaping (NavigationTransitionContext) -> Void) {
        self.container = container
        self.isPresenting = isPresenting
        self.from = from
        self.to = to
        self.onUpdate = onUpdate
        self.isInteractive = isInteractive
        self.isCompleting = true
        self.isCompleted = false
        (from as? RootViewType)?.willDisappear(animated: true)
        (to as? RootViewType)?.willAppear(animated: true)
    }

    public func completeTransition() {
        guard !isCompleted else {
            assertionFailure("Transition is already completed")
            return
        }
        isCompleted = true
        if isCompleting {
            (from as? RootViewType)?.didDisappear(animated: true)
            (to as? RootViewType)?.didAppear(animated: true)
        } else {
            (to as? RootViewType)?.didDisappear(animated: true)
            (from as? RootViewType)?.didAppear(animated: true)
        }
        onUpdate(self)
    }

    public func beginInteractiveTransition() {
        guard !isCompleted else {
            assertionFailure("Transition is already completed")
            return
        }
        isInteractive = true
    }

    public func endInteractiveTransition(_ isCompleting: Bool) {
        guard !isCompleted else {
            assertionFailure("Transition is already completed")
            return
        }
        isInteractive = false
        if isCompleting != self.isCompleting {
            (from as? RootViewType)?.willAppear(animated: true)
            (to as? RootViewType)?.willDisappear(animated: true)
            self.isCompleting = isCompleting
            onUpdate(self)
        }
    }
}
