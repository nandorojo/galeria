import UIKit
import ExpoModulesCore
import ImageViewer_swift
import SDWebImage

class GaleriaView: ExpoView {
    lazy var imageView:UIImageView = {
        let iv = UIImageView()
        
        // Setup Image Viewer With URL
        iv.setupImageViewer(url: URL(string: "https://res.cloudinary.com/dn29xlaeh/image/upload/q_75,w_768,fl_lossy/beatgig-prod/aig6jybsqxey3jdr6hlr")!)
        return iv
    }()
    

  required init(appContext: AppContext? = nil) {
    super.init(appContext: appContext)

    // change self background color
    self.backgroundColor = .black

    addSubview(imageView)
 
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor, constant: 20).isActive = true
    imageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
    imageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
    imageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
  }
}
 
