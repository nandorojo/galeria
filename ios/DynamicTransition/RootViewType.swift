//
//  RootViewType.swift
//  
//
//  Created by Luke Zhao on 6/4/24.
//

import UIKit

public protocol RootViewType: UIView {
    func willAppear(animated: Bool)
    func didAppear(animated: Bool)
    func willDisappear(animated: Bool)
    func didDisappear(animated: Bool)

    var preferredStatusBarStyle: UIStatusBarStyle { get }
    var prefersHomeIndicatorAutoHidden: Bool { get }
    var prefersStatusBarHidden: Bool { get }
}

public extension RootViewType {
    func willAppear(animated: Bool) {}
    func didAppear(animated: Bool) {}
    func willDisappear(animated: Bool) {}
    func didDisappear(animated: Bool) {}

    var preferredStatusBarStyle: UIStatusBarStyle { .default }
    var prefersHomeIndicatorAutoHidden: Bool { false }
    var prefersStatusBarHidden: Bool { false }
}
