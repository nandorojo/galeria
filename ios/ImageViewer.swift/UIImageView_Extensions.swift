import UIKit
import DynamicTransition

private var currentNavigationView: NavigationView?

extension UIImageView {

    private class TapWithDataRecognizer:UITapGestureRecognizer {
        weak var from:UIViewController?
        var imageDatasource:ImageDataSource?
        var imageLoader:ImageLoader?
        var initialIndex:Int = 0
        var options:[ImageViewerOption] = []
    }

    public func setupImageViewer(
        options:[ImageViewerOption] = [],
        from:UIViewController? = nil,
        imageLoader:ImageLoader? = nil) {
        setup(
            datasource: SimpleImageDatasource(imageItems: [.image(image)]),
            options: options,
            from: from,
            imageLoader: imageLoader)
    }

    public func setupImageViewer(
        url:URL,
        initialIndex:Int = 0,
        placeholder: UIImage? = nil,
        options:[ImageViewerOption] = [],
        from:UIViewController? = nil,
        imageLoader:ImageLoader? = nil) {

        let datasource = SimpleImageDatasource(
            imageItems: [url].compactMap {
                ImageItem.url($0, placeholder: placeholder)
        })
        setup(
            datasource: datasource,
            initialIndex: initialIndex,
            options: options,
            from: from,
            imageLoader: imageLoader)
    }

    public func setupImageViewer(
        images:[UIImage],
        initialIndex:Int = 0,
        options:[ImageViewerOption] = [],
        from:UIViewController? = nil,
        imageLoader:ImageLoader? = nil) {

        let datasource = SimpleImageDatasource(
            imageItems: images.compactMap {
                ImageItem.image($0)
        })
        setup(
            datasource: datasource,
            initialIndex: initialIndex,
            options: options,
            from: from,
            imageLoader: imageLoader)
    }

    public func setupImageViewer(
        urls:[URL],
        initialIndex:Int = 0,
        options:[ImageViewerOption] = [],
        placeholder: UIImage? = nil,
        from:UIViewController? = nil,
        imageLoader:ImageLoader? = nil) {

        let datasource = SimpleImageDatasource(
            imageItems: urls.compactMap {
                ImageItem.url($0, placeholder: placeholder)
        })
        setup(
            datasource: datasource,
            initialIndex: initialIndex,
            options: options,
            from: from,
            imageLoader: imageLoader)
    }

    public func setupImageViewer(
        datasource:ImageDataSource,
        initialIndex:Int = 0,
        options:[ImageViewerOption] = [],
        from:UIViewController? = nil,
        imageLoader:ImageLoader? = nil) {

        setup(
            datasource: datasource,
            initialIndex: initialIndex,
            options: options,
            from: from,
            imageLoader: imageLoader)
    }

    private func setup(
        datasource:ImageDataSource?,
        initialIndex:Int = 0,
        options:[ImageViewerOption] = [],
        from: UIViewController? = nil,
        imageLoader:ImageLoader? = nil) {

        var _tapRecognizer:TapWithDataRecognizer?
        gestureRecognizers?.forEach {
            if let _tr = $0 as? TapWithDataRecognizer {
                _tapRecognizer = _tr
            }
        }

        isUserInteractionEnabled = true

        var imageContentMode: UIView.ContentMode = .scaleAspectFill
        options.forEach {
            switch $0 {
            case .contentMode(let contentMode):
                imageContentMode = contentMode
            default:
                break
            }
        }
        contentMode = imageContentMode

        clipsToBounds = true

        if _tapRecognizer == nil {
            _tapRecognizer = TapWithDataRecognizer(
                target: self, action: #selector(showImageViewer(_:)))
            _tapRecognizer!.numberOfTouchesRequired = 1
            _tapRecognizer!.numberOfTapsRequired = 1
        }
        _tapRecognizer!.imageDatasource = datasource
        _tapRecognizer!.imageLoader = imageLoader
        _tapRecognizer!.initialIndex = initialIndex
        _tapRecognizer!.options = options
        _tapRecognizer!.from = from
        addGestureRecognizer(_tapRecognizer!)
    }

    @objc
    private func showImageViewer(_ sender:TapWithDataRecognizer) {
        guard let sourceView = sender.view as? UIImageView else { return }
        guard let window = sourceView.window else { return }

        let defaultImageLoader: ImageLoader
        #if canImport(SDWebImage)
        defaultImageLoader = SDWebImageLoader()
        #else
        defaultImageLoader = URLSessionImageLoader()
        #endif

        let imageLoader = sender.imageLoader ?? defaultImageLoader

        let galeriaView = sourceView.findSuperview(ofType: GaleriaView.self)

        let placeholderRoot = ImageViewerPlaceholderView(sourceImageView: sourceView, galeriaView: galeriaView)
        placeholderRoot.backgroundColor = .clear

        let navView = NavigationView(rootView: placeholderRoot)
        navView.frame = window.bounds
        navView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        window.addSubview(navView)
        currentNavigationView = navView

        // Get the source image for transition
        // Note: SDAnimatedImageView/ExpoImage may not return image via .image property
        // so we try multiple approaches
        let sourceImage: UIImage? = sourceView.image

        let viewerView = ImageViewerRootView(
            imageDataSource: sender.imageDatasource,
            imageLoader: imageLoader,
            options: sender.options,
            initialIndex: sender.initialIndex,
            sourceImage: sourceImage
        )

        viewerView.onDismiss = { [weak navView] in
            navView?.removeFromSuperview()
            currentNavigationView = nil
        }

        navView.pushView(viewerView, animated: true)
    }
}

extension UIView {
    func findSuperview<T: UIView>(ofType type: T.Type) -> T? {
        var currentView: UIView? = self
        while let view = currentView {
            if let typedView = view as? T {
                return typedView
            }
            currentView = view.superview
        }
        return nil
    }
}

class ImageViewerPlaceholderView: UIView, MatchTransitionDelegate {
    weak var sourceImageView: UIImageView?
    weak var galeriaView: GaleriaView?

    init(sourceImageView: UIImageView, galeriaView: GaleriaView?) {
        self.sourceImageView = sourceImageView
        self.galeriaView = galeriaView
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func matchedViewFor(transition: MatchTransition, otherView: UIView) -> UIView? {
        if let galeriaView = galeriaView {
            let result = galeriaView.matchedViewFor(transition: transition, otherView: otherView)
            return result
        }
        return sourceImageView
    }

    func matchTransitionWillBegin(transition: MatchTransition) {
        galeriaView?.matchTransitionWillBegin(transition: transition)
    }
}
