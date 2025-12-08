//
//  TransitionContext.swift
//
//
//  Created by Luke Zhao on 6/4/24.
//

import UIKit

public protocol TransitionContext {
    var from: UIView { get }
    var to: UIView { get }
    var container: UIView { get }
    var isPresenting: Bool { get }
    var isCompleting: Bool { get }

    func completeTransition()

    // interactive
    func beginInteractiveTransition()
    func endInteractiveTransition(_ isCompleting: Bool)
}

public extension TransitionContext {
    var foreground: UIView {
        isPresenting ? to : from
    }
    var background: UIView {
        isPresenting ? from : to
    }
}
