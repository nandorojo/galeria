import ExpoModulesCore
import ImageViewer_swift
import UIKit

class GaleriaView: ExpoView {
    var urls: [String]? { didSet { setupImageView() } }
    var index: Int? { didSet { setupImageView() } }
    
    override func insertReactSubview(_ subview: UIView!, at atIndex: Int) {
        super.insertReactSubview(subview, at: atIndex)
        setupImageView()
    }
    
    func setupImageView() {
        guard let imageView = reactSubviews()?.compactMap({
            $0.subviews.compactMap { $0 as? UIImageView }.first }).first,
              let urls = self.urls?.compactMap(URL.init(string:)),
              let index = self.index
        else { return }
        
        imageView.setupImageViewer(urls: urls, initialIndex: index)
    }
}


























//
//class GaleriaView: ExpoView {
//    
//    var urls: [String]? { didSet { setupImageView() } }
//    var index: Int? { didSet { setupImageView() } }
//
//  override func insertReactSubview(_ subview: UIView!, at atIndex: Int) {
//    super.insertReactSubview(subview, at: atIndex)
//    setupImageView()
//  }
//
//  private func setupImageView() {
//    guard let imageView = reactSubviews()?.compactMap({ $0.subviews.compactMap { $0 as? UIImageView }.first }).first,
//          let index = self.index,
//          let urls = self.urls else { return }
//    imageView.setupImageViewer(urls: urls.compactMap(URL.init(string:)), initialIndex: index)
//  }
//}

//import ExpoModulesCore
//import ImageViewer_swift
//import UIKit
//
//class GaleriaView: ExpoView {
//  var urls: [String]? { didSet { setupImageView() } }
//  var index: Int? { didSet { setupImageView() } }
//
//  private func getChildImageView() -> UIImageView? {
//    guard let reactSubviews = self.reactSubviews() else { return nil }
//
//    for reactSubview in reactSubviews {
//      for subview in reactSubview.subviews {
//        if let imageView = subview as? UIImageView {
//          return imageView
//        }
//      }
//    }
//
//    return nil
//  }
//
//  override func insertReactSubview(_ subview: UIView!, at atIndex: Int) {
//    super.insertReactSubview(subview, at: atIndex)
//    setupImageView()
//  }
//
//  private func setupImageView() {
//    guard let childImageView = getChildImageView() else {
//      return
//    }
//
//    if let index = self.index, let urls = self.urls {
//      childImageView.setupImageViewer(
//        urls: urls.compactMap(URL.init(string:)),
//        initialIndex: index
//      )
//    }
//  }
//}

