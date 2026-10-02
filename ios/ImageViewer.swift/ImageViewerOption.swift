import UIKit

public enum ImageViewerOption {
    case autoPlayVideo(Bool)
    case theme(ImageViewerTheme)
    case contentMode(UIView.ContentMode)
    case closeIcon(UIImage)
    case rightNavItemTitle(String, onTap: ((Int) -> Void)?)
    case rightNavItemIcon(UIImage, onTap: ((Int) -> Void)?)
    case onIndexChange((_ index: Int) -> Void)
    case onDismiss(() -> Void)
    case hideBlurOverlay(Bool)
    case hidePageIndicators(Bool)
}
