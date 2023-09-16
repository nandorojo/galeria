// Copyright 2022-present 650 Industries. All rights reserved.

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

      Prop("src") { (view, src: String) in
        view.src = src
      }

      Prop("urls") { (view, urls: [String]?) in
        view.urls = urls
      }

      Prop("initialIndex") { (view, initialIndex: Int?) in
        view.initialIndex = initialIndex
      }
    }
  }
}
