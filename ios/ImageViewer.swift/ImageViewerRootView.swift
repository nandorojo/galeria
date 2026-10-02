import UIKit

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
    private let groupId: String?
    var hideBlurOverlay: Bool = false
    var hidePageIndicators: Bool = false
    private var autoPlayVideo = false
    private var isVisible = false

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
    private var initialViewController: UIViewController?

    private var currentPage: GalleryPage? {
        (pageViewController?.viewControllers?.first ?? initialViewController) as? GalleryPage
    }

    var currentImageView: UIImageView? { currentPage?.transitionImageView }
    var currentScrollView: UIScrollView? { currentPage?.zoomScrollView }

    private func updatePlayback() {
        (currentPage as? VideoViewerController)?.setActive(isVisible, autoPlayVideo: autoPlayVideo)
    }

    private func makePage(index: Int, datasource: ImageDataSource) -> UIViewController {
        let item = datasource.imageItem(at: index)
        if case .video(let url) = item {
            let thumbnail = groupId.flatMap {
                GaleriaView.findView(groupId: $0, index: index)?.getChildImageView()?.image
            }
            return VideoViewerController(index: index, url: url,
                placeholder: thumbnail ?? (index == initialIndex ? sourceImage : nil))
        }
        let page = ImageViewerController(index: index, imageItem: item, imageLoader: imageLoader)
        if index == initialIndex { page.initialPlaceholder = sourceImage }
        return page
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
        isVisible = true
        updatePlayback()
        UIView.animate(withDuration: 0.25) {
            self.navBar.alpha = 1.0
        }
    }

    func willDisappear(animated: Bool) {
        isVisible = false
        updatePlayback()
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
        sourceImage: UIImage? = nil,
        groupId: String? = nil
    ) {
        self.imageDatasource = imageDataSource
        self.imageLoader = imageLoader
        self.options = options
        self.initialIndex = initialIndex
        self.currentIndex = initialIndex
        self.sourceImage = sourceImage
        self.groupId = groupId

        for option in options {
            if case .hidePageIndicators(let hide) = option {
                self.hidePageIndicators = hide
            }
        }

        super.init(frame: .zero)
        accessibilityViewIsModal = true
        setupViews()
        applyOptions()
        setupGestures()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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
            let initialVC = makePage(index: initialIndex, datasource: datasource)
            self.initialViewController = initialVC

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

    private func applyOptions() {
        let closeButton = navItem.rightBarButtonItem
        
        options.forEach { option in
            switch option {
            case .autoPlayVideo(let value):
                autoPlayVideo = value
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
        singleTapGesture.cancelsTouchesInView = false
        singleTapGesture.delegate = self
        addGestureRecognizer(singleTapGesture)
    }

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

extension ImageViewerRootView: TransitionProvider {
    func transitionFor(presenting: Bool, otherView: UIView) -> Transition? {
        return transition
    }
}

extension ImageViewerRootView: MatchTransitionDelegate {
    func matchedViewFor(transition: MatchTransition, otherView: UIView) -> UIView? {
        let imageView = currentImageView
        return imageView
    }

    func matchTransitionWillBegin(transition: MatchTransition) {
        navBar.alpha = 0
        transition.overlayView?.isHidden = hideBlurOverlay
    }
}

extension ImageViewerRootView: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if currentPage is VideoViewerController {
            if gestureRecognizer is UITapGestureRecognizer { return false }
            if let pan = gestureRecognizer as? UIPanGestureRecognizer {
                let velocity = pan.velocity(in: self)
                let point = pan.location(in: self)
                // Leave the player's bottom controls and horizontal scrubbing alone.
                return abs(velocity.y) > abs(velocity.x) && point.y < bounds.height - 180
            }
        }
        if let scrollView = currentScrollView {
            return scrollView.zoomScale <= scrollView.minimumZoomScale + 0.01
        }
        return true
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        return false
    }
}

extension ImageViewerRootView: UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let vc = viewController as? GalleryPage,
              let datasource = imageDatasource,
              vc.index > 0 else {
            return nil
        }

        let newIndex = vc.index - 1
        let newVC = makePage(index: newIndex, datasource: datasource)
        newVC.view.gestureRecognizers?.removeAll(where: { $0 is UIPanGestureRecognizer })
        return newVC
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let vc = viewController as? GalleryPage,
              let datasource = imageDatasource,
              vc.index < datasource.numberOfImages() - 1 else {
            return nil
        }

        let newIndex = vc.index + 1
        let newVC = makePage(index: newIndex, datasource: datasource)
        newVC.view.gestureRecognizers?.removeAll(where: { $0 is UIPanGestureRecognizer })
        return newVC
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

extension ImageViewerRootView: UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        if completed, let currentVC = pageViewController.viewControllers?.first as? GalleryPage {
            for previous in previousViewControllers {
                (previous as? VideoViewerController)?.setActive(false, autoPlayVideo: autoPlayVideo)
            }
            currentIndex = currentVC.index
            updatePlayback()
            onIndexChange?(currentIndex)
        }
    }
}
