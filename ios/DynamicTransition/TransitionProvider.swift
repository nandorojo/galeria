//
//  TransitionProvider.swift
//
//
//  Created by Luke Zhao on 6/4/24.
//

import UIKit

public protocol TransitionProvider {
    func transitionFor(presenting: Bool, otherView: UIView) -> Transition?
}
