import Foundation

extension DispatchQueue {
    public func delay(_ delay: TimeInterval = 0, execute: @escaping () -> Void) {
        asyncAfter(deadline: .now() + delay, execute: execute)
    }
    
    public func delay(_ delay: TimeInterval = 0, execute: DispatchWorkItem) {
        asyncAfter(deadline: .now() + delay, execute: execute)
    }
}

/// Delay on main queue.
public func delay(_ delay: TimeInterval = 0, execute: @escaping () -> Void) {
    DispatchQueue.main.delay(delay, execute: execute)
}

/// Delay on main queue.
public func delay(_ delay: TimeInterval = 0, execute: DispatchWorkItem) {
    DispatchQueue.main.delay(delay, execute: execute)
}

extension DispatchQueue {
    /// Dispatch the block to main queue asynchronously if needed.
    public static func onMainAsync(_ block: @escaping () -> Void) {
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.async {
                block()
            }
        }
    }
    
    /// Dispatch the block to main queue synchronously if needed.
    public static func onMainSync(_ block: @escaping () -> Void) {
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.sync {
                block()
            }
        }
    }
}
