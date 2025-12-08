
#if canImport(UIKit)

import UIKit

// configurable methods
public enum BaseToolbox {
    @_spi(CustomPresentation)
    public static var customPresentationMethod: ((UIView, UIViewController, (() -> Void)?) -> ())?

    @_spi(CustomPresentation)
    public static var customPushMethod: ((UIView, UIViewController) -> ())?

    @_spi(CustomPresentation)
    public static var customDismissMethod: ((UIView, (() -> Void)?) -> ())?
}

#endif
