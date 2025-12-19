import ExpoModulesCore
import UIKit
import DynamicTransition

class GaleriaView: ExpoView {
  private var childImageView: UIImageView?
  private weak var currentNavigationView: NavigationView?
  private weak var previousFirstResponder: UIResponder?
  private var isRegistered = false
  
  var groupId: String? {
    guard let urls = urls, !urls.isEmpty else { return nil }
    return String(urls.joined(separator: ",").hashValue)
  }
  
  deinit {
    unregisterFromRegistry()
  }
  
  private func registerWithRegistry() {
    guard let groupId = groupId, let index = initialIndex else { return }
    GaleriaViewRegistry.shared.register(view: self, groupId: groupId, index: index)
    isRegistered = true
  }
  
  private func unregisterFromRegistry() {
    guard isRegistered, let groupId = groupId, let index = initialIndex else { return }
    GaleriaViewRegistry.shared.unregister(groupId: groupId, index: index)
    isRegistered = false
  }
  
  class func findView(groupId: String, index: Int) -> GaleriaView? {
    return GaleriaViewRegistry.shared.view(forGroupId: groupId, index: index)
  }

  func getChildImageView() -> UIImageView? {
    var reactSubviews: [UIView]? = nil
    if RCTIsNewArchEnabled() {
      reactSubviews = self.subviews
    } else {
      reactSubviews = self.reactSubviews()
    }

    guard let reactSubviews else { return nil }

    for reactSubview in reactSubviews {
      for subview in reactSubview.subviews {
        if let imageView = subview as? UIImageView {
          childImageView = imageView
          return imageView
        }
      }
    }

    return nil
  }

  #if !RCT_NEW_ARCH_ENABLED
    override func insertReactSubview(_ subview: UIView!, at atIndex: Int) {
      super.insertReactSubview(subview, at: atIndex)
      setupImageView()
    }
  #endif

  #if RCT_NEW_ARCH_ENABLED
    // https://github.com/nandorojo/galeria/issues/19
    // Cleanup gesture recognizers from the image view to work with fabric view recycling
    override func unmountChildComponentView(_ childComponentView: UIView, index: Int) {
      childImageView?.gestureRecognizers?.removeAll()
      childImageView = nil
      unregisterFromRegistry()
      super.unmountChildComponentView(childComponentView, index: index)
    }
  #endif

  var theme: Theme = .dark
  var urls: [String]?
  var initialIndex: Int?
  var closeIconName: String?
  var rightNavItemIconName: String?
  let onPressRightNavItemIcon = EventDispatcher()
  let onIndexChange = EventDispatcher()

  public func setupImageView() {
    let viewerTheme = theme.toImageViewerTheme()
    guard let childImage = getChildImageView() else {
      return
    }

    registerWithRegistry()

    if let urls = self.urls, let initialIndex = self.initialIndex {
      setupImageViewerWithUrls(
        childImage, urls: urls, initialIndex: initialIndex, viewerTheme: viewerTheme)
    } else {
      setupImageViewerWithSingleImage(childImage, viewerTheme: viewerTheme)
    }
  }

  private func setupImageViewerWithUrls(
    _ childImage: UIImageView,
    urls: [String],
    initialIndex: Int,
    viewerTheme: ImageViewerTheme
  ) {
    let options = buildImageViewerOptions()

    let urlObjects: [URL] = urls.compactMap { string in
      if string.hasPrefix("http://") || string.hasPrefix("https://") || string.hasPrefix("file://") {
        return URL(string: string)
      }
      return URL(fileURLWithPath: string)
    }

    childImage.setupImageViewer(urls: urlObjects, initialIndex: initialIndex, options: options)
  }

  private func setupImageViewerWithSingleImage(
    _ childImage: UIImageView, viewerTheme: ImageViewerTheme
  ) {
    guard let img = childImage.image else {
      print("Missing image in childImage: \(childImage)")
      return
    }
    let options = buildImageViewerOptions()

    childImage.setupImageViewer(images: [img], options: options)
  }

  private func buildImageViewerOptions() -> [ImageViewerOption] {
    let viewerTheme = theme.toImageViewerTheme()
    var options: [ImageViewerOption] = [.theme(viewerTheme)]
    let iconColor = theme.iconColor()

    if let closeIconName = closeIconName,
      let closeIconImage = UIImage(systemName: closeIconName)?.withTintColor(
        iconColor, renderingMode: .alwaysOriginal)
    {
      options.append(ImageViewerOption.closeIcon(closeIconImage))

    }

    if let rightIconName = rightNavItemIconName,
      let rightIconImage = UIImage(systemName: rightIconName)?.withTintColor(
        iconColor, renderingMode: .alwaysOriginal)
    {
      let rightNavItemOption = ImageViewerOption.rightNavItemIcon(
        rightIconImage,
        onTap: { index in
          self.onPressRightNavItemIcon(["index": index])
        })
      options.append(rightNavItemOption)
    }

    options.append(
      .onIndexChange { [weak self] index in
        self?.onIndexChange(["currentIndex": index])
      })
      
      options.append(
        .onDismiss { [weak self] in
            self?.restoreKeyboard()
        })

    return options
  }
}

enum Theme: String, Enumerable {
  case dark
  case light

  func toImageViewerTheme() -> ImageViewerTheme {
    switch self {
    case .dark:
      return .dark
    case .light:
      return .light
    }
  }
  func iconColor() -> UIColor {
    return UIColor.label
  }
}

extension GaleriaView: MatchTransitionDelegate {
  func matchedViewFor(transition: MatchTransition, otherView: UIView) -> UIView? {
    guard let imageView = childImageView else { return nil }

    if let parentCornerRadius = findCornerRadius(for: imageView), parentCornerRadius > 0 {
      imageView.layer.cornerRadius = parentCornerRadius
      imageView.clipsToBounds = true
    }

    return imageView
  }

    func matchTransitionWillBegin(transition: MatchTransition) {
        guard previousFirstResponder == nil else { return }
        
        previousFirstResponder = UIResponder.currentFirstResponder
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func restoreKeyboard() {
        previousFirstResponder?.becomeFirstResponder()
        previousFirstResponder = nil
    }

  private func findCornerRadius(for view: UIView) -> CGFloat? {
    var current: UIView? = view.superview
    while let parent = current {
      if parent.layer.cornerRadius > 0 {
        return parent.layer.cornerRadius
      }
      if parent === self {
        break
      }
      current = parent.superview
    }
    return nil
  }
}

extension UIResponder {
    private static weak var _currentFirstResponder: UIResponder?
    
    static var currentFirstResponder: UIResponder? {
        _currentFirstResponder = nil
        UIApplication.shared.sendAction(#selector(findFirstResponder(_:)), to: nil, from: nil, for: nil)
        return _currentFirstResponder
    }
    
    @objc private func findFirstResponder(_ sender: Any) {
        UIResponder._currentFirstResponder = self
    }
}
