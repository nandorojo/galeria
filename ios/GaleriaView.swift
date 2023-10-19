import UIKit
import ExpoModulesCore
import ImageViewer_swift
import SDWebImage

class GaleriaView: ExpoView {
    lazy var imageView: SDAnimatedImageView = {
        let iv = SDAnimatedImageView(frame: .zero)
        setupImageView()
        return iv
    }()

    var recyclingKey: String? {
        didSet {
            if recyclingKey != oldValue {
                imageView.image = nil
            }
        }
    }

    var theme: String? {
        didSet {
            setupImageView()
        }
    }

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
        var viewerTheme: ImageViewerTheme = .dark
        if let theme = self.theme {
            viewerTheme = Theme(rawValue: theme)?.toImageViewerTheme() ?? .dark
        }
        if let src = self.src, let url = URL(string: src) {
            imageView.sd_setImage(with: url, placeholderImage: nil)
            
            if let urls = self.urls, let initialIndex = self.initialIndex {
                let urlObjects = urls.compactMap { URL(string: $0) }
                imageView.setupImageViewer(urls: urlObjects, initialIndex: initialIndex, options: [.theme(viewerTheme)])
            } else {
                imageView.setupImageViewer(url: url, options: [.theme(viewerTheme)])
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


enum Theme: String, Enumerable {
  case dark
  case light
  
  func toImageViewerTheme() -> ImageViewerTheme {
    switch self {
        case .dark:
            return .dark
        case .light:
            return .light
    }
  }
}