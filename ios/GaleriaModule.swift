import ExpoModulesCore 

open class GaleriaModule: Module {
  public func definition() -> ModuleDefinition {
    Name("Galeria")
    
    View(GaleriaView.self) {
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
    }
  }
}

