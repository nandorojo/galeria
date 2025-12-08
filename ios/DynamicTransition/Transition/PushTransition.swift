//
//  PushTransition.swift
//
//
//  Created by Luke Zhao on 10/12/23.
//

import UIKit

open class PushTransition: InteractiveTransition {
    public lazy var horizontalDismissGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gr:))).then {
        $0.delegate = self
        if #available(iOS 13.4, *) {
            $0.allowedScrollTypesMask = .all
        }
    }
    private lazy var interruptibleHorizontalDismissGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gr:))).then {
        $0.delegate = self
        if #available(iOS 13.4, *) {
            $0.allowedScrollTypesMask = .all
        }
    }

    public var overlayView: UIView?
    private var totalTranslation: CGPoint = .zero

    open override func canTransitionSimutanously(with transition: Transition) -> Bool {
        transition is PushTransition || transition is MatchTransition
    }

    open override func setupTransition(context: any TransitionContext, animator: TransitionAnimator) {
        let container = context.container
        let foregroundView = context.foreground
        let backgroundView = context.background
        let overlayView = UIView()
        overlayView.backgroundColor = .black.withAlphaComponent(0.4)
        overlayView.isUserInteractionEnabled = true
        overlayView.frame = container.bounds

        foregroundView.frame = container.bounds

        if foregroundView.superview == container {
            container.insertSubview(backgroundView, belowSubview: foregroundView)
        } else if backgroundView.window == nil {
            container.addSubview(backgroundView)
        }
        backgroundView.addSubview(overlayView)
        backgroundView.addSubview(foregroundView)
        container.addGestureRecognizer(interruptibleHorizontalDismissGestureRecognizer)

        foregroundView.setNeedsLayout()
        foregroundView.layoutIfNeeded()
        foregroundView.lockedSafeAreaInsets = container.safeAreaInsets

        animator[foregroundView, \.translationX].dismissedValue = container.bounds.width
        animator[overlayView, \.alpha].dismissedValue = 0

        self.overlayView = overlayView
    }

    open override func animationWillStart(targetPosition: TransitionEndPosition) {
        guard let context else { return }
        let isPresenting = targetPosition == .presented
        if isPresenting {
            context.container.addGestureRecognizer(interruptibleHorizontalDismissGestureRecognizer)
        } else {
            interruptibleHorizontalDismissGestureRecognizer.view?.removeGestureRecognizer(interruptibleHorizontalDismissGestureRecognizer)
        }
        context.foreground.isUserInteractionEnabled = isPresenting
        overlayView?.isUserInteractionEnabled = isPresenting
    }

    open override func cleanupTransition(endPosition: TransitionEndPosition) {
        guard let context else { return }
        context.foreground.lockedSafeAreaInsets = nil
        context.foreground.isUserInteractionEnabled = true
        overlayView?.removeFromSuperview()
        context.container.removeGestureRecognizer(interruptibleHorizontalDismissGestureRecognizer)
    }

    @objc private func handlePan(gr: UIPanGestureRecognizer) {
        guard let view = gr.view else { return }
        func progressFrom(offset: CGPoint) -> CGFloat {
            guard let context else { return 0 }
            let container = context.container
            let progress = offset.x / container.bounds.width
            return -progress
        }
        switch gr.state {
        case .began:
            beginInteractiveTransition()
            if context == nil, let navigationView = view.navigationView, navigationView.views.count > 1 {
                navigationView.popView(animated: true)
            }
            totalTranslation = .zero
        case .changed:
            guard let animator else { return }
            let translation = gr.translation(in: nil)
            gr.setTranslation(.zero, in: nil)
            totalTranslation += translation
            let progress = progressFrom(offset: translation)
            animator.shift(progress: progress)
        default:
            guard let context, let animator else { return }
            let velocity = gr.velocity(in: nil)
            let translationPlusVelocity = totalTranslation + velocity / 2
            let shouldDismiss = translationPlusVelocity.x > 80
            animator[context.foreground, \.translationX].velocity = velocity.x
            animateTo(position: shouldDismiss ? .dismissed : .presented)
        }
    }
}

extension PushTransition: UIGestureRecognizerDelegate {
    open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer else { return false }
        let velocity = gestureRecognizer.velocity(in: nil)
        if gestureRecognizer == interruptibleHorizontalDismissGestureRecognizer || gestureRecognizer == horizontalDismissGestureRecognizer {
            if velocity.x > abs(velocity.y) {
                return true
            }
        }
        return false
    }

    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer is UIPanGestureRecognizer, let scrollView = otherGestureRecognizer.view as? UIScrollView, otherGestureRecognizer == scrollView.panGestureRecognizer {
            if scrollView.contentSize.width > scrollView.bounds.inset(by: scrollView.adjustedContentInset).width, gestureRecognizer == interruptibleHorizontalDismissGestureRecognizer || gestureRecognizer == horizontalDismissGestureRecognizer {
                return scrollView.contentOffset.x <= -scrollView.adjustedContentInset.left + 1.0
            }
            return true
        }
        return false
    }
}
