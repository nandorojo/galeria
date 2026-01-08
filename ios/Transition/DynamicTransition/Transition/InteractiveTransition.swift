import UIKit

/// ## InteractiveTransition
///
/// A base class for implementing interactive transition
/// It provides an `animator` object that can be used to animate the transition.
/// This base class conforms to the `Transition` protocol. Instead of implementing `animateTransition(context:)` directly,
/// subclass should implement `setupTransition(context:animator:)` to setup the transition animator.
/// The only other `Transition` protocol method that can be overriden is the `canTransitionSimutanously(with:)` method, the rest are implemented for you.
///
/// Subclass should not call any `TransitionContext` methods directly (like `beginInteractiveTransition()`, `endInteractiveTransition(_:)`, or `completeTransition(_:)`)
/// `InteractiveTransition` already handled these methods for you.
/// Instead, call the corresponding methods on the `InteractiveTransition` itself:
/// * `beginInteractiveTransition()` - to pause the animation and begin interactive transition
/// * `animateTo(position:)` - to animate to a specific position or to resume the animation after interaction
///
/// Below are all the methods that can be overriden:
/// * `canTransitionSimutanously(with:)` - to determine if the transition can be performed simutanously with another transition. Default is false.
/// * `setupTransition(context:animator:)` - to setup the transition animator. This will only be called once before the transition start.
/// * `animationWillStart(targetPosition:)` - to perform any setup before the animation starts. This can be called multiple times.
/// * `cleanupTransition(endPosition:)` - to perform any cleanup after the transition ends. This will only be called once before the transition ends.
/// Subclass don't need to call super in these methods. (super implementation does nothing)
///
open class InteractiveTransition: NSObject, Transition {
    public private(set) var context: TransitionContext?
    public private(set) var animator: TransitionAnimator?
    public private(set) var isInteractive: Bool = false

    public var response: CGFloat = 0.3
    public var dampingRatio: CGFloat = 1.0

    public var isAnimating: Bool {
        animator?.isAnimating ?? false
    }

    // MARK: - Transition protocol methods

    public var wantsInteractiveStart: Bool {
        isInteractive
    }

    public func animateTransition(context: TransitionContext) {
        let animator = TransitionAnimator(response: response, dampingRatio: dampingRatio)
        animator.addCompletion { position in
            self.didCompleteTransitionAnimation(position: position)
        }
        self.context = context
        self.animator = animator

        CATransaction.begin()
        setupTransition(context: context, animator: animator)
        animator.seekTo(position: context.isPresenting ? .dismissed : .presented)
        CATransaction.commit()

        TransitionContainerTracker.shared.transitionStart(from: context.from, to: context.to)

        if !isInteractive {
            animateTo(position: context.isPresenting ? .presented : .dismissed)
        }
    }

    public func reverse() {
        guard let targetPosition = animator?.targetPosition else { return }
        beginInteractiveTransition()
        animateTo(position: targetPosition.reversed)
    }

    // MARK: - Private

    private func didCompleteTransitionAnimation(position: TransitionEndPosition) {
        guard let context else { return }
        cleanupTransition(endPosition: position)
        let didComplete = (position == .presented) == context.isPresenting
        TransitionContainerTracker.shared.transitionEnd(from: context.from, to: context.to, completed: didComplete)
        self.animator = nil
        self.context = nil
        self.isInteractive = false
        context.completeTransition()
    }

    // MARK: - Subclass callable

    public func beginInteractiveTransition() {
        isInteractive = true
        animator?.pause()
        context?.beginInteractiveTransition()
    }

    public func animateTo(position: TransitionEndPosition) {
        guard let animator, let context else {
            assertionFailure()
            return
        }
        if isInteractive {
            isInteractive = false
            context.endInteractiveTransition((position == .presented) == context.isPresenting)
        }
        animationWillStart(targetPosition: position)
        animator.animateTo(position: position)
    }
    
    public func forceCompletion(position: TransitionEndPosition) {
        guard let animator, let context else {
            assertionFailure()
            return
        }
        if isInteractive {
            isInteractive = false
            context.endInteractiveTransition((position == .presented) == context.isPresenting)
        }
        animationWillStart(targetPosition: position)
        animator.forceCompletion(position: position)
    }

    // MARK: - Subclass hooks

    open func canTransitionSimutanously(with transition: any Transition) -> Bool {
        false
    }

    open func setupTransition(context: TransitionContext, animator: TransitionAnimator) {
    }

    open func animationWillStart(targetPosition: TransitionEndPosition) {
    }

    open func cleanupTransition(endPosition: TransitionEndPosition) {
    }
}
