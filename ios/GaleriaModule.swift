import ExpoModulesCore

public class GaleriaModule: Module {
  public func definition() -> ModuleDefinition {
    Name("Galeria")

    View(GaleriaView.self) {
        Prop("index") { (view, index: Int?) in
            view.index = index
        }
        Prop("urls") { (view, urls: [String]?) in
            view.urls = urls
        }
    }
  }
}
