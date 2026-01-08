import Foundation

public class InstantTransition: NSObject, Transition {
    public func animateTransition(context: TransitionContext) {
        let container = context.container
        let from = context.from
        let to = context.to

        to.frame = container.bounds
        container.addSubview(to)
        to.setNeedsLayout()
        to.layoutIfNeeded()

        from.removeFromSuperview()
        context.completeTransition()
    }
}
