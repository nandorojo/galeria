import UIKit

// MARK: - Protocol shared by ImageViewerController and VideoViewerController

protocol GaleriaPageViewController: AnyObject {
    var index: Int { get }
}

extension ImageViewerController: GaleriaPageViewController {}
extension VideoViewerController: GaleriaPageViewController {}

// MARK: - ImageViewerRootView

class ImageViewerRootView: UIView, RootViewType {
    let transition = MatchTransition()

    weak var imageDatasource: ImageDataSource?
    let imageLoader: ImageLoader
    var initialIndex: Int = 0
    var theme: ImageViewerTheme = .dark
    var options: [ImageViewerOption] = []
    var onIndexChange: ((Int) -> Void)?
    var onDismiss: (() -> Void)?
    var sourceImage: UIImage?
    var hideBlurOverlay: Bool = false
    var hidePageIndicators: Bool = false

    private var pageViewController: UIPageViewController!
    private(set) lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = theme.color
        return view
    }()

    private(set) lazy var navBar: UINavigationBar = {
        let navBar = UINavigationBar(frame: .zero)
        navBar.isTranslucent = true
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        return navBar
    }()

    private lazy var navItem = UINavigationItem()
    private var onRightNavBarTapped: ((Int) -> Void)?

    private(set) var currentIndex: Int = 0
    /// Holds the initial VC (image or video) before pageVC takes over.
    private var initialViewController: UIViewController?

    // MARK: - Current views (for transition matching & pan dismiss)

    var currentImageView: UIImageView? {
        let vc = pageViewController?.viewControllers?.first ?? initialViewController
        if let imageVC = vc as? ImageViewerController {
            return imageVC.imageView
        }
        if let videoVC = vc as? VideoViewerController {
            return videoVC.thumbnailImageView
        }
        return nil
    }

    var currentScrollView: UIScrollView? {
        let vc = pageViewController?.viewControllers?.first ?? initialViewController
        if let imageVC = vc as? ImageViewerController {
            return imageVC.scrollView
        }
        // Videos don't have a scroll view — returning nil lets pan dismiss work freely
        return nil
    }

    var preferredStatusBarStyle: UIStatusBarStyle {
        theme == .dark ? .lightContent : .default
    }

    var prefersStatusBarHidden: Bool { false }
    var prefersHomeIndicatorAutoHidden: Bool { false }

    func willAppear(animated: Bool) {
        navBar.alpha = 0
    }

    func didAppear(animated: Bool) {
        UIView.animate(withDuration: 0.25) {
            self.navBar.alpha = 1.0
        }
    }

    func willDisappear(animated: Bool) {
        UIView.animate(withDuration: 0.25) {
            self.navBar.alpha = 0
        }
    }

    func didDisappear(animated: Bool) {
        onDismiss?()
    }

    init(
        imageDataSource: ImageDataSource?,
        imageLoader: ImageLoader,
        options: [ImageViewerOption] = [],
        initialIndex: Int = 0,
        sourceImage: UIImage? = nil
    ) {
        self.imageDatasource = imageDataSource
        self.imageLoader = imageLoader
        self.options = options
        self.initialIndex = initialIndex
        self.currentIndex = initialIndex
        self.sourceImage = sourceImage

        for option in options {
            if case .hidePageIndicators(let hide) = option {
                self.hidePageIndicators = hide
            }
        }

        super.init(frame: .zero)
        setupViews()
        applyOptions()
        setupGestures()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupViews() {
        addSubview(backgroundView)

        let pageOptions = [UIPageViewController.OptionsKey.interPageSpacing: 20]
        pageViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: pageOptions
        )
        pageViewController.dataSource = self
        pageViewController.delegate = self
        pageViewController.view.backgroundColor = .clear

        addSubview(pageViewController.view)

        if let datasource = imageDatasource {
            let initialVC = makeViewController(for: initialIndex, datasource: datasource)
            self.initialViewController = initialVC

            if let imageVC = initialVC as? ImageViewerController, let sourceImage = self.sourceImage {
                imageVC.initialPlaceholder = sourceImage
            }

            initialVC.view.gestureRecognizers?.removeAll(where: { $0 is UIPanGestureRecognizer })
            pageViewController.setViewControllers([initialVC], direction: .forward, animated: false)

            initialVC.view.setNeedsLayout()
            initialVC.view.layoutIfNeeded()

            onIndexChange?(initialIndex)
        }

        let closeBarButton = UIBarButtonItem(
            title: NSLocalizedString("Close", comment: "Close button title"),
            style: .plain,
            target: self,
            action: #selector(dismissViewer)
        )
        closeBarButton.tintColor = theme.tintColor
        navItem.rightBarButtonItem = closeBarButton
        navBar.items = [navItem]
        addSubview(navBar)
    }

    // MARK: - Factory

    /// Creates the correct VC type (image or video) for the given index.
    private func makeViewController(for index: Int, datasource: ImageDataSource) -> UIViewController {
        let item = datasource.imageItem(at: index)
        let vc: UIViewController
        if case .video(let url, let placeholder) = item {
            let videoVC = VideoViewerController(index: index, videoURL: url, placeholder: placeholder)
            vc = videoVC
        } else {
            let imageVC = ImageViewerController(index: index, imageItem: item, imageLoader: imageLoader)
            vc = imageVC
        }
        vc.view.gestureRecognizers?.removeAll(where: { $0 is UIPanGestureRecognizer })
        return vc
    }

    private func applyOptions() {
        let closeButton = navItem.rightBarButtonItem

        options.forEach { option in
            switch option {
            case .theme(let newTheme):
                self.theme = newTheme
                backgroundView.backgroundColor = newTheme.color
                closeButton?.tintColor = newTheme.tintColor
            case .closeIcon(let icon):
                closeButton?.image = icon
            case .rightNavItemTitle(let title, let onTap):
                let customButton = UIBarButtonItem(
                    title: title,
                    style: .plain,
                    target: self,
                    action: #selector(didTapRightNavItem)
                )
                if let closeButton = closeButton {
                    navItem.rightBarButtonItems = [closeButton, customButton]
                } else {
                    navItem.rightBarButtonItem = customButton
                }
                onRightNavBarTapped = onTap
            case .rightNavItemIcon(let icon, let onTap):
                let customButton = UIBarButtonItem(
                    image: icon,
                    style: .plain,
                    target: self,
                    action: #selector(didTapRightNavItem)
                )
                if let closeButton = closeButton {
                    navItem.rightBarButtonItems = [closeButton, customButton]
                } else {
                    navItem.rightBarButtonItem = customButton
                }
                onRightNavBarTapped = onTap
            case .onIndexChange(let callback):
                self.onIndexChange = callback
            case .onDismiss(let callback):
                self.onDismiss = callback
            case .contentMode:
                break
            case .hideBlurOverlay(let hide):
                self.hideBlurOverlay = hide
            case .hidePageIndicators(let hide):
                self.hidePageIndicators = hide
            }
        }
    }

    private func setupGestures() {
        addGestureRecognizer(transition.verticalDismissGestureRecognizer)
        transition.verticalDismissGestureRecognizer.delegate = self

        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(didSingleTap))
        singleTapGesture.numberOfTapsRequired = 1
        addGestureRecognizer(singleTapGesture)
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundView.frame = bounds
        pageViewController.view.frame = bounds

        pageViewController.view.setNeedsLayout()
        pageViewController.view.layoutIfNeeded()
        for child in pageViewController.children {
            child.view.setNeedsLayout()
            child.view.layoutIfNeeded()
        }

        let navBarHeight: CGFloat = 44
        let statusBarHeight = safeAreaInsets.top
        let horizontalPadding: CGFloat = 16
        navBar.frame = CGRect(
            x: horizontalPadding,
            y: statusBarHeight,
            width: bounds.width - (horizontalPadding * 2),
            height: navBarHeight
        )
    }

    // MARK: - Actions

    @objc private func dismissViewer() {
        navigationView?.popView(animated: true)
    }

    @objc private func didSingleTap() {
        let currentAlpha = navBar.alpha
        UIView.animate(withDuration: 0.235) {
            self.navBar.alpha = currentAlpha > 0.5 ? 0.0 : 1.0
        }
    }

    @objc private func didTapRightNavItem() {
        onRightNavBarTapped?(currentIndex)
    }
}

// MARK: - TransitionProvider

extension ImageViewerRootView: TransitionProvider {
    func transitionFor(presenting: Bool, otherView: UIView) -> Transition? {
        return transition
    }
}

// MARK: - MatchTransitionDelegate

extension ImageViewerRootView: MatchTransitionDelegate {
    func matchedViewFor(transition: MatchTransition, otherView: UIView) -> UIView? {
        return currentImageView
    }

    func matchTransitionWillBegin(transition: MatchTransition) {
        navBar.alpha = 0
        transition.overlayView?.isHidden = hideBlurOverlay
    }
}

// MARK: - UIGestureRecognizerDelegate

extension ImageViewerRootView: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let scrollView = currentScrollView {
            return scrollView.zoomScale <= scrollView.minimumZoomScale + 0.01
        }
        // No scroll view (e.g. video) — always allow pan-to-dismiss
        return true
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        return false
    }
}

// MARK: - UIPageViewControllerDataSource

extension ImageViewerRootView: UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let indexed = viewController as? GaleriaPageViewController,
              let datasource = imageDatasource,
              indexed.index > 0 else {
            return nil
        }

        let newIndex = indexed.index - 1
        return makeViewController(for: newIndex, datasource: datasource)
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let indexed = viewController as? GaleriaPageViewController,
              let datasource = imageDatasource,
              indexed.index < datasource.numberOfImages() - 1 else {
            return nil
        }

        let newIndex = indexed.index + 1
        return makeViewController(for: newIndex, datasource: datasource)
    }

    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        guard !hidePageIndicators else { return 0 }
        let count = imageDatasource?.numberOfImages() ?? 0
        return count > 1 ? count : 0
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return currentIndex
    }
}

// MARK: - UIPageViewControllerDelegate

extension ImageViewerRootView: UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard completed else { return }

        // Pause any video that was previously playing
        for previous in previousViewControllers {
            if let videoVC = previous as? VideoViewerController {
                videoVC.pause()
            }
        }

        if let currentVC = pageViewController.viewControllers?.first {
            // Auto-play if the new page is a video
            if let videoVC = currentVC as? VideoViewerController {
                videoVC.play()
            }

            if let indexed = currentVC as? GaleriaPageViewController {
                currentIndex = indexed.index
                onIndexChange?(currentIndex)
            }
        }
    }
}
