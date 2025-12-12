//
//  ImageViewerRootView.swift
//  Galeria
//
//  Created for DynamicTransition integration
//

import UIKit
import DynamicTransition

class ImageViewerRootView: UIView, RootViewType {
    let transition = MatchTransition()

    // MARK: - Data
    weak var imageDatasource: ImageDataSource?
    let imageLoader: ImageLoader
    var initialIndex: Int = 0
    var theme: ImageViewerTheme = .dark
    var options: [ImageViewerOption] = []
    var onIndexChange: ((Int) -> Void)?
    var onDismiss: (() -> Void)?

    // Source image used for transition (displayed immediately while full image loads)
    var sourceImage: UIImage?

    // MARK: - Views
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

    // MARK: - State
    private var currentIndex: Int = 0

    // Store direct reference to initial view controller for transition matching
    private var initialViewController: ImageViewerController?

    // MARK: - Computed Properties
    var currentImageView: UIImageView? {
        // Try pageViewController first
        if let vc = pageViewController?.viewControllers?.first as? ImageViewerController {
            print("[ImageViewerRootView] currentImageView from pageVC: \(vc.imageView)")
            return vc.imageView
        }
        // Fall back to stored initial view controller
        if let vc = initialViewController {
            print("[ImageViewerRootView] currentImageView from initialVC: \(vc.imageView)")
            return vc.imageView
        }
        print("[ImageViewerRootView] currentImageView: nil")
        return nil
    }

    var currentScrollView: UIScrollView? {
        if let vc = pageViewController?.viewControllers?.first as? ImageViewerController {
            return vc.scrollView
        }
        return initialViewController?.scrollView
    }

    // MARK: - RootViewType
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

    // MARK: - Init
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
        print("[ImageViewerRootView] init: sourceImage = \(String(describing: sourceImage))")
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
        // Background
        addSubview(backgroundView)

        // Page view controller
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

        // Set initial view controller
        if let datasource = imageDatasource {
            let initialVC = ImageViewerController(
                index: initialIndex,
                imageItem: datasource.imageItem(at: initialIndex),
                imageLoader: imageLoader
            )
            // Store reference for transition matching
            self.initialViewController = initialVC

            // Remove the pan gesture from ImageViewerController since MatchTransition handles it
            // Accessing .view triggers viewDidLoad
            initialVC.view.gestureRecognizers?.removeAll(where: { $0 is UIPanGestureRecognizer })
            pageViewController.setViewControllers([initialVC], direction: .forward, animated: false)

            // Pre-populate with source image for transition animation
            // IMPORTANT: This must happen AFTER viewDidLoad (triggered by accessing .view above)
            // because viewDidLoad may overwrite the image when loading from URL
            print("[ImageViewerRootView] setupViews: self.sourceImage = \(String(describing: self.sourceImage))")
            if let sourceImage = self.sourceImage {
                print("[ImageViewerRootView] setupViews: Setting sourceImage on imageView (after viewDidLoad)")
                initialVC.imageView.image = sourceImage
                initialVC.imageView.contentMode = .scaleAspectFit
                print("[ImageViewerRootView] setupViews: imageView.image after setting = \(String(describing: initialVC.imageView.image))")
            } else {
                print("[ImageViewerRootView] setupViews: sourceImage is nil, not setting")
            }

            // Force layout so imageView has proper frame before transition
            initialVC.view.setNeedsLayout()
            initialVC.view.layoutIfNeeded()

            onIndexChange?(initialIndex)
            print("[ImageViewerRootView] setupViews: initialVC set, imageView = \(initialVC.imageView), image = \(String(describing: initialVC.imageView.image))")
        }

        // Nav bar
        let closeBarButton = UIBarButtonItem(
            title: NSLocalizedString("Close", comment: "Close button title"),
            style: .plain,
            target: self,
            action: #selector(dismissViewer)
        )
        navItem.leftBarButtonItem = closeBarButton
        navItem.leftBarButtonItem?.tintColor = theme.tintColor
        navBar.items = [navItem]
        addSubview(navBar)
    }

    private func applyOptions() {
        options.forEach { option in
            switch option {
            case .theme(let newTheme):
                self.theme = newTheme
                backgroundView.backgroundColor = newTheme.color
                navItem.leftBarButtonItem?.tintColor = newTheme.tintColor
            case .closeIcon(let icon):
                navItem.leftBarButtonItem?.image = icon
            case .rightNavItemTitle(let title, let onTap):
                navItem.rightBarButtonItem = UIBarButtonItem(
                    title: title,
                    style: .plain,
                    target: self,
                    action: #selector(didTapRightNavItem)
                )
                onRightNavBarTapped = onTap
            case .rightNavItemIcon(let icon, let onTap):
                navItem.rightBarButtonItem = UIBarButtonItem(
                    image: icon,
                    style: .plain,
                    target: self,
                    action: #selector(didTapRightNavItem)
                )
                onRightNavBarTapped = onTap
            case .onIndexChange(let callback):
                self.onIndexChange = callback
            case .contentMode:
                break // Handled by ImageViewerController
            }
        }
    }

    private func setupGestures() {
        // Vertical pan to dismiss
        addGestureRecognizer(transition.verticalDismissGestureRecognizer)
        transition.verticalDismissGestureRecognizer.delegate = self

        // Single tap to toggle nav bar
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(didSingleTap))
        singleTapGesture.numberOfTapsRequired = 1
        addGestureRecognizer(singleTapGesture)
    }

    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundView.frame = bounds
        pageViewController.view.frame = bounds

        // Force layout on page view controller's children so imageView gets proper frame
        pageViewController.view.setNeedsLayout()
        pageViewController.view.layoutIfNeeded()
        for child in pageViewController.children {
            child.view.setNeedsLayout()
            child.view.layoutIfNeeded()
        }

        // Layout nav bar
        let navBarHeight: CGFloat = 44
        let statusBarHeight = safeAreaInsets.top
        navBar.frame = CGRect(
            x: 0,
            y: statusBarHeight,
            width: bounds.width,
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
        // Return the current image view as the matched element
        let imageView = currentImageView
        print("[ImageViewerRootView] matchedViewFor called, returning: \(String(describing: imageView)), otherView: \(type(of: otherView))")
        return imageView
    }

    func matchTransitionWillBegin(transition: MatchTransition) {
        // Hide nav bar during transition
        navBar.alpha = 0
        print("[ImageViewerRootView] matchTransitionWillBegin")
    }
}

// MARK: - UIGestureRecognizerDelegate
extension ImageViewerRootView: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // Disable dismiss gesture when zoomed in
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

// MARK: - UIPageViewControllerDataSource
extension ImageViewerRootView: UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let vc = viewController as? ImageViewerController,
              let datasource = imageDatasource,
              vc.index > 0 else {
            return nil
        }

        let newIndex = vc.index - 1
        let newVC = ImageViewerController(
            index: newIndex,
            imageItem: datasource.imageItem(at: newIndex),
            imageLoader: imageLoader
        )
        // Remove pan gesture
        newVC.view.gestureRecognizers?.removeAll(where: { $0 is UIPanGestureRecognizer })
        return newVC
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let vc = viewController as? ImageViewerController,
              let datasource = imageDatasource,
              vc.index < datasource.numberOfImages() - 1 else {
            return nil
        }

        let newIndex = vc.index + 1
        let newVC = ImageViewerController(
            index: newIndex,
            imageItem: datasource.imageItem(at: newIndex),
            imageLoader: imageLoader
        )
        // Remove pan gesture
        newVC.view.gestureRecognizers?.removeAll(where: { $0 is UIPanGestureRecognizer })
        return newVC
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
        if completed, let currentVC = pageViewController.viewControllers?.first as? ImageViewerController {
            currentIndex = currentVC.index
            onIndexChange?(currentIndex)
        }
    }
}
