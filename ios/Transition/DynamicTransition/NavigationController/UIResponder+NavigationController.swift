import UIKit

public extension UIView {
    @objc var navigationView: NavigationView? {
        var responder: UIResponder? = self
        while let current = responder {
            if let navigationView = current as? NavigationView {
                return navigationView
            }
            responder = current.next
        }
        return nil
    }

    @objc var navigationController: NavigationController? {
        var responder: UIResponder? = self
        while let current = responder {
            if let current = current as? NavigationController {
                return current
            }
            responder = current.next
        }
        return nil
    }
}
