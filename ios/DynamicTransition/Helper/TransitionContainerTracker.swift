//
//  TransitionContainerTracker.swift
//
//
//  Created by Luke Zhao on 11/1/23.
//

import UIKit

class TransitionContainerTracker {
    static let shared = TransitionContainerTracker()

    class ContainerContext {
        var presentedCount: Int = 0
        var transitionCount: Int = 0
    }
    private var containers: [UIView: ContainerContext] = [:]

    func transitionStart(from: UIView, to: UIView) {
        if self[from].presentedCount == 0, self[from].transitionCount == 0 {
            self[from].presentedCount = 1 // source should be already presented
        }
        self[from].transitionCount += 1
        self[to].transitionCount += 1
    }

    func transitionEnd(from: UIView, to: UIView, completed: Bool) {
        self[from].transitionCount -= 1
        self[to].transitionCount -= 1
        self[from].presentedCount -= completed ? 1 : 0
        self[to].presentedCount += completed ? 1 : 0
        cleanupContainers()
    }

    private func cleanupContainers() {
        var toBeRemoved: [UIView] = []
        var toKeepContainers: Set<UIView> = containers.keys.set
        for (view, context) in containers {
            //            print("\(type(of: view)): \(context.transitionCount) \(context.presentedCount)")
            if context.transitionCount <= 0 && context.presentedCount <= 0 {
                toBeRemoved.append(view)
                toKeepContainers.remove(view)
            }
        }
        for toBeRemove in toBeRemoved {
            for childToKeep in toBeRemove.subviews.filter({ toKeepContainers.contains($0) }) {
                toBeRemove.superview?.insertSubview(childToKeep, aboveSubview: toBeRemove)
            }
            toBeRemove.removeFromSuperview()
            containers[toBeRemove] = nil
        }
    }

    private subscript(view: UIView) -> ContainerContext {
        get {
            if containers[view] == nil {
                containers[view] = ContainerContext()
            }
            return containers[view]!
        }
        set {
            containers[view] = newValue
        }
    }
}
