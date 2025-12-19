import Foundation

private final class WeakGaleriaViewRef {
    weak var view: GaleriaView?
    
    init(_ view: GaleriaView) {
        self.view = view
    }
}

final class GaleriaViewRegistry {
    static let shared = GaleriaViewRegistry()
    
    private var views: [String: [Int: WeakGaleriaViewRef]] = [:]
    private let lock = NSLock()
    
    private init() {}
    
    func register(view: GaleriaView, groupId: String, index: Int) {
        lock.lock()
        defer { lock.unlock() }
        
        if views[groupId] == nil {
            views[groupId] = [:]
        }
        views[groupId]?[index] = WeakGaleriaViewRef(view)
    }
    
    func unregister(groupId: String, index: Int) {
        lock.lock()
        defer { lock.unlock() }
        
        views[groupId]?[index] = nil
        
        if views[groupId]?.isEmpty == true {
            views[groupId] = nil
        }
    }
    
    func view(forGroupId groupId: String, index: Int) -> GaleriaView? {
        lock.lock()
        defer { lock.unlock() }
        
        return views[groupId]?[index]?.view
    }
    
    func cleanup() {
        lock.lock()
        defer { lock.unlock() }
        
        for (groupId, indexMap) in views {
            views[groupId] = indexMap.filter { $0.value.view != nil }
            if views[groupId]?.isEmpty == true {
                views[groupId] = nil
            }
        }
    }
}

