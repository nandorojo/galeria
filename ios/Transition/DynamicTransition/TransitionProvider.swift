import UIKit

public protocol TransitionProvider {
    func transitionFor(presenting: Bool, otherView: UIView) -> Transition?
}
