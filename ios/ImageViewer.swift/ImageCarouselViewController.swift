import ExpoModulesCore
import UIKit

public protocol ImageDataSource: AnyObject {
    func numberOfImages() -> Int
    func imageItem(at index: Int) -> ImageItem
}

// MARK: - Deprecated: ImageCarouselViewController
// This class is deprecated in favor of ImageViewerRootView which uses DynamicTransition.
// Kept for backwards compatibility but will be removed in a future version.

@available(*, deprecated, message: "Use ImageViewerRootView with NavigationView instead")
public class ImageCarouselViewController: UIPageViewController {
    weak var imageDatasource: ImageDataSource?
    let imageLoader: ImageLoader

    var initialIndex = 0

    var theme: ImageViewerTheme = .light {
        didSet {
            navItem.leftBarButtonItem?.tintColor = theme.tintColor
            backgroundView?.backgroundColor = theme.color
        }
    }

    var imageContentMode: UIView.ContentMode = .scaleAspectFill
    var options: [ImageViewerOption] = []

    private var onRightNavBarTapped: ((Int) -> Void)?

    private(set) lazy var navBar: UINavigationBar = {
        let _navBar = UINavigationBar(frame: .zero)
        _navBar.isTranslucent = true
        _navBar.setBackgroundImage(UIImage(), for: .default)
        _navBar.shadowImage = UIImage()
        return _navBar
    }()

    private(set) lazy var backgroundView: UIView? = {
        let _v = UIView()
        _v.backgroundColor = theme.color
        _v.alpha = 1.0
        return _v
    }()

    private(set) lazy var navItem = UINavigationItem()

    var onIndexChange: ((Int) -> Void)?

    public init(
        imageDataSource: ImageDataSource?,
        imageLoader: ImageLoader,
        options: [ImageViewerOption] = [],
        initialIndex: Int = 0
    ) {
        self.initialIndex = initialIndex
        self.options = options
        self.imageDatasource = imageDataSource
        self.imageLoader = imageLoader
        let pageOptions = [UIPageViewController.OptionsKey.interPageSpacing: 20]

        var _imageContentMode = imageContentMode
        options.forEach {
            switch $0 {
            case .contentMode(let contentMode):
                _imageContentMode = contentMode
            default:
                break
            }
        }
        imageContentMode = _imageContentMode

        super.init(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: pageOptions
        )

        modalPresentationCapturesStatusBarAppearance = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addNavBar() {
        let closeBarButton = UIBarButtonItem(
            title: NSLocalizedString("Close", comment: "Close button title"),
            style: .plain,
            target: self,
            action: #selector(dismissVC(_:))
        )

        navItem.leftBarButtonItem = closeBarButton
        navItem.leftBarButtonItem?.tintColor = theme.tintColor
        navBar.alpha = 0.0
        navBar.items = [navItem]
        navBar.insert(to: view)
    }

    private func addBackgroundView() {
        guard let backgroundView = backgroundView else { return }
        view.addSubview(backgroundView)
        backgroundView.bindFrameToSuperview()
        view.sendSubviewToBack(backgroundView)
    }

    private func applyOptions() {
        options.forEach {
            switch $0 {
            case .theme(let theme):
                self.theme = theme
            case .contentMode(let contentMode):
                self.imageContentMode = contentMode
            case .closeIcon(let icon):
                navItem.leftBarButtonItem?.image = icon
            case .rightNavItemTitle(let title, let onTap):
                navItem.rightBarButtonItem = UIBarButtonItem(
                    title: title,
                    style: .plain,
                    target: self,
                    action: #selector(didTapRightNavBarItem(_:))
                )
                onRightNavBarTapped = onTap
            case .rightNavItemIcon(let icon, let onTap):
                navItem.rightBarButtonItem = UIBarButtonItem(
                    image: icon,
                    style: .plain,
                    target: self,
                    action: #selector(didTapRightNavBarItem(_:))
                )
                onRightNavBarTapped = onTap
            case .onIndexChange(let callback):
                self.onIndexChange = callback
            }
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        addBackgroundView()
        addNavBar()
        applyOptions()

        dataSource = self
        delegate = self

        if let imageDatasource = imageDatasource {
            let initialVC = ImageViewerController(
                index: initialIndex,
                imageItem: imageDatasource.imageItem(at: initialIndex),
                imageLoader: imageLoader
            )
            setViewControllers([initialVC], direction: .forward, animated: true)
            onIndexChange?(initialIndex)
        }
    }

    @objc
    private func dismissVC(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    @objc
    func didTapRightNavBarItem(_ sender: UIBarButtonItem) {
        guard let onTap = onRightNavBarTapped,
              let firstVC = viewControllers?.first as? ImageViewerController
        else { return }
        onTap(firstVC.index)
    }

    override public var preferredStatusBarStyle: UIStatusBarStyle {
        theme == .dark ? .lightContent : .default
    }
}

@available(*, deprecated, message: "Use ImageViewerRootView with NavigationView instead")
extension ImageCarouselViewController: UIPageViewControllerDataSource {
    public func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let vc = viewController as? ImageViewerController,
              let imageDatasource = imageDatasource,
              vc.index > 0 else {
            return nil
        }

        let newIndex = vc.index - 1
        return ImageViewerController(
            index: newIndex,
            imageItem: imageDatasource.imageItem(at: newIndex),
            imageLoader: vc.imageLoader
        )
    }

    public func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let vc = viewController as? ImageViewerController,
              let imageDatasource = imageDatasource,
              vc.index <= (imageDatasource.numberOfImages() - 2) else {
            return nil
        }

        let newIndex = vc.index + 1
        return ImageViewerController(
            index: newIndex,
            imageItem: imageDatasource.imageItem(at: newIndex),
            imageLoader: vc.imageLoader
        )
    }
}

@available(*, deprecated, message: "Use ImageViewerRootView with NavigationView instead")
extension ImageCarouselViewController: UIPageViewControllerDelegate {
    public func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        if completed, let currentVC = viewControllers?.first as? ImageViewerController {
            onIndexChange?(currentVC.index)
        }
    }
}