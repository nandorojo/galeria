import UIKit

public protocol NavigationDelegate: AnyObject {
    func navigationDidUpdate(views: [UIView])
}

open class NavigationView: UIView, RootViewType {

    struct TransitionState {
        let context: NavigationTransitionContext
        let transition: Galeria.Transition
        let source: [UIView]
        let target: [UIView]
    }

    struct NavigationState {
        var baseViews: [UIView]
        var transitions: [TransitionState] = []
        var nextAction: (NavigationAction, Bool)?

        var currentViews: [UIView] {
            transitions.last(where: { $0.context.isCompleting })?.target ?? baseViews
        }
    }

    public enum NavigationAction {
        case push(UIView)
        case dismiss(UIView)
        case pop
        case popToRoot
        case set([UIView])

        func target(from source: [UIView]) -> [UIView] {
            switch self {
            case .push(let vc):
                return source + [vc]
            case .dismiss(let vc):
                guard let index = source.firstIndex(of: vc) else {
                    assertionFailure("The View doesn't exist in the NavigationController's stack")
                    return source
                }
                return source[0..<max(1, index)].array
            case .pop:
                return source[0..<max(1, source.count - 1)].array
            case .popToRoot:
                return [source.first!]
            case .set(let vcs):
                guard !vcs.isEmpty else {
                    assertionFailure("Cannot set empty view controllers to NavigationController")
                    return source
                }
                return vcs
            }
        }
    }

    public weak var delegate: NavigationDelegate?
    public var onDidUpdateViews: (([UIView]) -> Void)?

    public var defaultTransition: Galeria.Transition = PushTransition()

    public private(set) var views: [UIView] {
        didSet {
            guard views != oldValue else { return }
            didUpdateViews()
            delegate?.navigationDidUpdate(views: views)
            onDidUpdateViews?(views)
            updateStatusBarStyle()
            setNeedsLayout()
        }
    }

    private var _preferredStatusBarStyle: UIStatusBarStyle = .default {
        didSet {
            guard _preferredStatusBarStyle != oldValue else { return }
            UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState]) {
                self.parentViewController?.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }

    private var _preferredStatusBarHidden: Bool = false {
        didSet {
            guard _preferredStatusBarHidden != oldValue else { return }
            UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState]) {
                self.parentViewController?.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }

    private var _preferredHomeIndicatorAutoHidden: Bool = false {
        didSet {
            guard _preferredHomeIndicatorAutoHidden != oldValue else { return }
            UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState]) {
                self.parentViewController?.setNeedsUpdateOfHomeIndicatorAutoHidden()
            }
        }
    }

    public var preferredStatusBarStyle: UIStatusBarStyle {
        _preferredStatusBarStyle
    }

    public var prefersStatusBarHidden: Bool {
        _preferredStatusBarHidden
    }

    public var prefersHomeIndicatorAutoHidden: Bool {
        _preferredHomeIndicatorAutoHidden
    }

    private var state: NavigationState {
        didSet {
            updateViews()
        }
    }
    private var hasAppeared = false

    public var topView: UIView {
        views.last!
    }

    public init(rootView: UIView) {
        state = NavigationState(baseViews: [rootView])
        views = state.currentViews
        super.init(frame: .zero)
        setupCustomPresentation()
        addSubview(rootView)
        updateStatusBarStyle()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        for subview in subviews {
            subview.frameWithoutTransform = bounds
        }
    }

    open override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !(parentViewController is NavigationController) else { return }
        if window != nil && !hasAppeared {
            willAppear(animated: false)
            didAppear(animated: false)
        } else if window == nil && hasAppeared {
            willDisappear(animated: false)
            didDisappear(animated: false)
        }
    }

    open func transitionFor(isPresenting: Bool, from: UIView, to: UIView) -> Galeria.Transition {
        let foreground = isPresenting ? to : from
        let background = isPresenting ? from : to
        return (foreground as? TransitionProvider)?.transitionFor(presenting: isPresenting, otherView: background) ?? defaultTransition
    }

    // MARK: - Navigation methods

    open func pushView(_ view: UIView, animated: Bool = true) {
        navigate(.push(view), animated: animated)
    }

    open func popView(animated: Bool = true) {
        navigate(.pop, animated: animated)
    }

    open func popToRootView(animated: Bool = true) {
        navigate(.popToRoot, animated: animated)
    }

    open func dismissToView(_ view: UIView, animated: Bool = true) {
        navigate(.dismiss(view), animated: animated)
    }

    open func setViews(_ views: [UIView], animated: Bool = true) {
        navigate(.set(views), animated: animated)
    }

    // MARK: - RootViewType

    public func willAppear(animated: Bool) {
        (topView as? RootViewType)?.willAppear(animated: animated)
    }

    public func didAppear(animated: Bool) {
        (topView as? RootViewType)?.didAppear(animated: animated)
        hasAppeared = true
    }

    public func willDisappear(animated: Bool) {
        (topView as? RootViewType)?.willDisappear(animated: animated)
    }

    public func didDisappear(animated: Bool) {
        (topView as? RootViewType)?.didDisappear(animated: animated)
        hasAppeared = false
    }

    // MARK: - Private methods

    private func navigate(_ navigationAction: NavigationAction, animated: Bool) {
        let source = views
        let target = navigationAction.target(from: source)
        guard target != source, let to = target.last, let from = source.last else { return }
        guard from != to else {
            // TODO: This might need more work. Will get overriden.
            state.baseViews = target
            return
        }
        let isPresenting = target.count >= source.count
        let transition = animated ? transitionFor(isPresenting: isPresenting, from: from, to: to) : InstantTransition()

        if let transitionState = state.transitions.first(where: { $0.transition === transition }) {
            // the transition is already running
            if transitionState.target == source, transitionState.source == target {
                // reverse the transition
                transitionState.transition.reverse()
            }
            return
        }

        guard state.transitions.isEmpty || state.transitions.allSatisfy({ $0.transition.canTransitionSimutanously(with: transition) && transition.canTransitionSimutanously(with: $0.transition) }) else {
            // can't transition simutanously
            state.nextAction = (navigationAction, animated)
            return
        }

        let isInteractiveStart = transition.wantsInteractiveStart
        let context = NavigationTransitionContext(container: self, isPresenting: isPresenting, from: from, to: to, isInteractive: isInteractiveStart) { [weak self] context in
            self?.didUpdateTransition(context)
        }
        let transitionState = TransitionState(context: context, transition: transition, source: source, target: target)
        state.transitions.append(transitionState)
        transition.animateTransition(context: context)
    }

    private func didUpdateTransition(_ context: NavigationTransitionContext) {
        if state.transitions.allSatisfy({ $0.context.isCompleted }) {
            // all transition completed, cleanup
            let nextAction = state.nextAction
            self.state = .init(baseViews: views, transitions: [], nextAction: nil)
            if let (navigationAction, animated) = nextAction {
                navigate(navigationAction, animated: animated)
            }
        } else {
            updateViews()
        }
    }

    private func updateViews() {
        views = state.currentViews
    }

    // Subclass override
    open func didUpdateViews() {

    }

    public func updateStatusBarStyle() {
        let topView = views.last.flatMap { $0 as? RootViewType }
        _preferredStatusBarStyle = topView?.preferredStatusBarStyle ?? .default
        _preferredStatusBarHidden = topView?.prefersStatusBarHidden ?? false
        _preferredHomeIndicatorAutoHidden = topView?.prefersHomeIndicatorAutoHidden ?? false
    }

    public func printState() {
        let views = views.map {
            "\(type(of: $0))"
        }
        let states = state.transitions.map {
            "\(type(of: $0.transition)): isPresenting=\($0.context.isPresenting) isCompleting=\($0.context.isCompleting) isCompleted=\($0.context.isCompleted)"
        }
        print("""
        --------------------------------
        Transitions:
        \(states.joined(separator: "\n"))

        Views:
        \(views.joined(separator: "\n"))
        --------------------------------
        """)
    }
}
