//
//  NavigationController.swift
//
//
//  Created by Luke Zhao on 10/6/23.
//

import UIKit

@available(*, deprecated, renamed: "NavigationDelegate")
public protocol NavigationControllerDelegate: NavigationDelegate {
    func navigationControllerDidUpdate(views: [UIView])
}

extension NavigationControllerDelegate {
    public func navigationDidUpdate(views: [UIView]) {
        navigationControllerDidUpdate(views: views)
    }
}

open class NavigationController: UIViewController {
    public let navigationView: NavigationView

    public weak var delegate: NavigationDelegate? {
        get { navigationView.delegate }
        set { navigationView.delegate = newValue }
    }

    public var defaultTransition: Galeria.Transition {
        get { navigationView.defaultTransition }
        set { navigationView.defaultTransition = newValue }
    }

    public var views: [UIView] {
        navigationView.views
    }

    public var topView: UIView {
        navigationView.topView
    }

    public init(rootView: UIView) {
        navigationView = NavigationView(rootView: rootView)
        super.init(nibName: nil, bundle: nil)
        navigationView.onDidUpdateViews = { [weak self] _ in
            self?.didUpdateViews()
        }
        didUpdateViews()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func loadView() {
        view = navigationView
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationView.willAppear(animated: animated)
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationView.didAppear(animated: animated)
    }

    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationView.didDisappear(animated: animated)
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationView.willDisappear(animated: animated)
    }

    // MARK: - Navigation methods

    open func pushView(_ view: UIView, animated: Bool = true) {
        navigationView.pushView(view, animated: animated)
    }

    open func popView(animated: Bool = true) {
        navigationView.popView(animated: animated)
    }

    open func popToRootView(animated: Bool = true) {
        navigationView.popToRootView(animated: animated)
    }

    open func dismissToView(_ view: UIView, animated: Bool = true) {
        navigationView.dismissToView(view, animated: animated)
    }

    open func setViews(_ views: [UIView], animated: Bool = true) {
        navigationView.setViews(views, animated: animated)
    }

    open override var preferredStatusBarStyle: UIStatusBarStyle {
        navigationView.preferredStatusBarStyle
    }

    open override var prefersStatusBarHidden: Bool {
        navigationView.prefersStatusBarHidden
    }

    open override var prefersHomeIndicatorAutoHidden: Bool {
        navigationView.prefersHomeIndicatorAutoHidden
    }

    // Subclass override
    open func didUpdateViews() {

    }

    public func printState() {
        navigationView.printState()
    }
}
