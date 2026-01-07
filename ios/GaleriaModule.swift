import ExpoModulesCore

public class GaleriaModule: Module {
  public func definition() -> ModuleDefinition {
    Name("Galeria")

    View(GaleriaView.self) {
      Events("onIndexChange")

      OnViewDidUpdateProps { (view) in
        view.setupImageView()
      }

      Prop("urls") { (view, urls: [String]?) in
        view.urls = urls
      }

      Prop("index") { (view, index: Int?) in
        view.initialIndex = index
      }

      Prop("theme") { (view, theme: Theme?) in
        view.theme = theme ?? .dark
      }
      Prop("closeIconName") { (view, closeIconName: String?) in
        view.closeIconName = closeIconName
      }
      Prop("rightNavItemIconName") { (view, rightNavItemIconName: String) in
        view.rightNavItemIconName = rightNavItemIconName
      }

      Prop("isBlurOverlayVisible") { (view, isBlurOverlayVisible: Bool?) in
        view.isBlurOverlayVisible = isBlurOverlayVisible ?? true
      }

    }
  }

  func onIndexChange(index: Int) {
    sendEvent("onIndexChange", ["currentIndex": index])
  }
}
