import UIKit
import ExpoModulesCore
import ImageViewer_swift
import SDWebImage

class GaleriaView: ExpoView {
    lazy var imageView:UIImageView = {
        let iv = SDAnimatedImageView(frame: .zero)
        setupImageView()
        return iv
    }()

    var src: String? {
        didSet {
            setupImageView()
        }
    }

    var urls: [String]? {
        didSet {
            setupImageView()
        }
    }

    var initialIndex: Int? {
        didSet {
            setupImageView()
        }
    }

    func setupImageView() {
        if let src = self.src {
            imageView.sd_setImage(with: URL(string: src)!, placeholderImage: nil)
            if let urls = self.urls, let initialIndex = self.initialIndex {
                imageView.setupImageViewer(urls: urls.map { URL(string: $0)! }, initialIndex: initialIndex)
            } else {
               imageView.setupImageViewer(url: URL(string: src)!)
            }
        }
    }

    required init(appContext: AppContext? = nil) {
        super.init(appContext: appContext)

        self.addSubview(imageView)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        imageView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    }  
}
