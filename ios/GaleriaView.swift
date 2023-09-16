import UIKit
import ExpoModulesCore
import ImageViewer_swift
import SDWebImage

class GaleriaView: ExpoView {
    lazy var imageView:UIImageView = {
        let iv = SDAnimatedImageView(frame: .zero)

        if let src = src {
            // Set an image with low resolution using SDWebImage
            iv.sd_setImage(with: URL(string: src)!, placeholderImage: nil)
            
            // Setup Image Viewer With URL
            iv.setupImageViewer(url: URL(string: src)!)
        }
        return iv
    }()

    var src: String? {
        didSet {
            if let src = src {
                // Set an image with low resolution using SDWebImage
                imageView.sd_setImage(with: URL(string: src)!, placeholderImage: nil)
                
                // Setup Image Viewer With URL
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
 
struct Data {
    
    static let imageNames:[String] = [
        "cat1",
        "cat2",
        "cat3",
        "cat4",
        "cat5",
        "cat1",
        "cat2",
        "cat3",
        "cat4",
        "cat5",
        "cat1",
        "cat2",
        "cat3",
        "cat4",
        "cat5",
        "cat1",
        "cat2",
        "cat3",
        "cat4",
        "cat5",
    ]
     
    static let imageUrls:[URL] = Self.imageNames.compactMap {
        URL(string: "https://raw.githubusercontent.com/michaelhenry/MHFacebookImageViewer/master/Example/Demo/Assets.xcassets/\($0).imageset/\($0).jpg")! }
}

