import UIKit
import ExpoModulesCore
import ImageViewer_swift

class GaleriaView: ExpoView {
  let imageView = UIImageView()

  required init(appContext: AppContext? = nil) {
    super.init(appContext: appContext)


    imageView.setupImageViewer(url: URL(string: "https://res.cloudinary.com/dn29xlaeh/image/upload/q_75,w_768,fl_lossy/beatgig-prod/aig6jybsqxey3jdr6hlr")!)

    addSubview(imageView)
 

    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor, constant: 20).isActive = true
    imageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
    imageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
    imageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
  }
}
 
