import ExpoModulesCore 

open class GaleriaModule: Module {
  public func definition() -> ModuleDefinition {
    Name("Galeria")

    View(GaleriaView.self) {
      Events(
        "onLoadStart",
        "onProgress",
        "onError",
        "onLoad"
      )

      Prop("urls") { (view, urls: [String]?) in
        view.urls = urls
      }

      Prop("index") { (view, index: Int?) in
        view.initialIndex = index
      }

      Prop("theme") { (view, theme: Theme?) in
        view.theme = theme
      }
    }
  }
}

