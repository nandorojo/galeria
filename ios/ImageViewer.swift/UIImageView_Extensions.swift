import UIKit

// Store weak reference to current navigation view for cleanup
private var currentNavigationView: NavigationView?

extension UIImageView {

    // Data holder tap recognizer
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
                // if found, just use existing
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
        // Pass the Data
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

        // Use SDWebImageLoader if available, otherwise fall back to URLSessionImageLoader
        let defaultImageLoader: ImageLoader
        #if canImport(SDWebImage)
        defaultImageLoader = SDWebImageLoader()
        #else
        defaultImageLoader = URLSessionImageLoader()
        #endif

        let imageLoader = sender.imageLoader ?? defaultImageLoader

        // Find the GaleriaView parent to use as MatchTransitionDelegate for background
        let galeriaView = sourceView.findSuperview(ofType: GaleriaView.self)

        // Create a placeholder root view for NavigationView
        // The placeholder acts as the "background" for the MatchTransition
        let placeholderRoot = ImageViewerPlaceholderView(sourceImageView: sourceView, galeriaView: galeriaView)
        placeholderRoot.backgroundColor = .clear

        // Create NavigationView
        let navView = NavigationView(rootView: placeholderRoot)
        navView.frame = window.bounds
        navView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        window.addSubview(navView)
        currentNavigationView = navView

        // Get the source image for transition
        // Note: SDAnimatedImageView/ExpoImage may not return image via .image property
        // so we try multiple approaches
        var sourceImage: UIImage? = sourceView.image
        print("[showImageViewer] sourceView.image = \(String(describing: sourceImage))")

        // If .image is nil, try to get the displayed image from the layer
        if sourceImage == nil {
//            sourceImage = UIImage(cgImage: cgImage)
            print("[showImageViewer] Got image from layer.contents: \(String(describing: sourceImage))")
        }

        // Create the image viewer with source image for transition
        let viewerView = ImageViewerRootView(
            imageDataSource: sender.imageDatasource,
            imageLoader: imageLoader,
            options: sender.options,
            initialIndex: sender.initialIndex,
            sourceImage: sourceImage
        )

        // Set up dismiss callback to clean up NavigationView
        viewerView.onDismiss = { [weak navView] in
            navView?.removeFromSuperview()
            currentNavigationView = nil
        }

        // Push the viewer onto the navigation stack
        navView.pushView(viewerView, animated: true)
    }
}

// MARK: - Helper extension to find superview of type
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

// MARK: - Placeholder view that acts as background during transition
class ImageViewerPlaceholderView: UIView, MatchTransitionDelegate {
    weak var sourceImageView: UIImageView?
    weak var galeriaView: GaleriaView?

    init(sourceImageView: UIImageView, galeriaView: GaleriaView?) {
        self.sourceImageView = sourceImageView
        self.galeriaView = galeriaView
        super.init(frame: .zero)
        print("[ImageViewerPlaceholderView] init with sourceImageView: \(String(describing: sourceImageView)), galeriaView: \(String(describing: galeriaView))")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func matchedViewFor(transition: MatchTransition, otherView: UIView) -> UIView? {
        // Return the source image view as the matched element
        // Either from GaleriaView or directly from the tapped image
        print("[ImageViewerPlaceholderView] matchedViewFor called, otherView: \(type(of: otherView))")
        if let galeriaView = galeriaView {
            let result = galeriaView.matchedViewFor(transition: transition, otherView: otherView)
            print("[ImageViewerPlaceholderView] returning from galeriaView: \(String(describing: result))")
            return result
        }
        print("[ImageViewerPlaceholderView] returning sourceImageView: \(String(describing: sourceImageView))")
        return sourceImageView
    }

    func matchTransitionWillBegin(transition: MatchTransition) {
        print("[ImageViewerPlaceholderView] matchTransitionWillBegin")
        galeriaView?.matchTransitionWillBegin(transition: transition)
    }
}
