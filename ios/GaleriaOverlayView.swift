import ExpoModulesCore
import UIKit

/// `Galeria.Overlay`: React views shown over the viewer of its group's images while it's open.
///
/// The viewer is added to the window, above React's root view. So this view keeps its children in a `Host` rather than
/// in itself, as Android's: it stays hidden where it's rendered (Fabric's own view, where it mounts and unmounts it),
/// while the viewer puts the host over its photos once open, and gives it back once closed. React's touch handler is a
/// gesture recognizer of its root view, which touches in the viewer don't reach: the host attaches one of its own
/// while in the viewer, as react-native-screens' `FullWindowOverlay` does.
class GaleriaOverlayView: ExpoView {
  private static let registry = NSMapTable<NSString, GaleriaOverlayView>.strongToWeakObjects()

  /// The overlay of the images whose urls are these (`GaleriaView.groupId`), if one is shown: the last one put in a
  /// window, e.g. of the same images opened again in a screen above.
  class func find(groupId: String) -> GaleriaOverlayView? {
    return registry.object(forKey: groupId as NSString)
  }

  var urls: [String]? {
    didSet {
      unregister(groupId(of: oldValue))
      register()
    }
  }

  /// The overlay's views, here (hidden) or over the photos of the viewer open.
  let host = Host()

  private var touchHandler: UIGestureRecognizer?

  required init(appContext: AppContext? = nil) {
    super.init(appContext: appContext)
    isHidden = true
    host.owner = self
    addSubview(host)
  }

  /// As `GaleriaView.groupId`.
  private func groupId(of urls: [String]?) -> String? {
    guard let urls, !urls.isEmpty else { return nil }
    return String(urls.joined(separator: ",").hashValue)
  }

  private func register() {
    if window != nil, let groupId = groupId(of: urls) {
      GaleriaOverlayView.registry.setObject(self, forKey: groupId as NSString)
    }
  }

  private func unregister(_ groupId: String?) {
    if let groupId, GaleriaOverlayView.registry.object(forKey: groupId as NSString) === self {
      GaleriaOverlayView.registry.removeObject(forKey: groupId as NSString)
    }
  }

  // Only while in a window: not once unmounted, nor while its screen is under another.
  override func didMoveToWindow() {
    super.didMoveToWindow()
    if window != nil {
      register()
    } else {
      unregister(groupId(of: urls))
    }
  }

  override func mountChildComponentView(_ childComponentView: UIView, index: Int) {
    host.insertSubview(childComponentView, at: index)
  }

  override func unmountChildComponentView(_ childComponentView: UIView, index: Int) {
    childComponentView.removeFromSuperview()
  }

  var isInViewer: Bool { host.superview !== self }

  func attach(to viewer: UIView) {
    guard !isInViewer else { return }
    viewer.addSubview(host)
    host.frame = viewer.bounds
    host.autoresizingMask = [.flexibleWidth, .flexibleHeight]

    // React Native's own (React/Fabric), found at runtime: this pod doesn't depend on React's headers.
    if touchHandler == nil, let handlerClass = NSClassFromString("RCTSurfaceTouchHandler") as? NSObject.Type {
      touchHandler = handlerClass.init() as? UIGestureRecognizer
    }
    touchHandler?.perform(NSSelectorFromString("attachToView:"), with: host)
  }

  func detach() {
    guard isInViewer else { return }
    touchHandler?.perform(NSSelectorFromString("detachFromView:"), with: host)
    host.alpha = 1
    addSubview(host)
    host.frame = bounds
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    if !isInViewer {
      host.frame = bounds
    }
  }

  class Host: UIView {
    weak var owner: GaleriaOverlayView?

    // The responder chain of where the overlay's rendered, even in the viewer (a view of the window's, with no view
    // controller): its views find their screen's controller there (e.g. SwiftUI's hosting ones, @expo/ui's menus).
    override var next: UIResponder? { owner ?? super.next }

    // Touches on nothing of the overlay's go to the photos under it.
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
      let view = super.hitTest(point, with: event)
      return view === self ? nil : view
    }
  }
}
