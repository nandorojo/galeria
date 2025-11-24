import UIKit

public enum ImageViewerTheme {
    case light
    case dark
    
    var color:UIColor {
        switch self {
            case .light:
                return .white
            case .dark:
                return .black
        }
    }
    
    var tintColor:UIColor {
        return UIColor.label
    }
}
