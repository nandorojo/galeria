import UIKit

public enum ImageItem {
    case video(URL)
    case image(UIImage?)
    case url(URL, placeholder: UIImage?)
}
