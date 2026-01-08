import Foundation

extension Collection {
    public var array: [Element] {
        Array(self)
    }
    
    /// Finds such index N that predicate is true for all elements up to
    /// but not including the index N, and is false for all elements
    /// starting with index N.
    /// Behavior is undefined if there is no such N.
    public func binarySearch(predicate: (Iterator.Element) -> Bool) -> Index {
        var low = startIndex
        var high = endIndex
        while low != high {
            let mid = index(low, offsetBy: distance(from: low, to: high) / 2)
            if predicate(self[mid]) {
                low = index(after: mid)
            } else {
                high = mid
            }
        }
        return low
    }
}

extension Collection where Element: Hashable {
    public var set: Set<Element> {
        Set(self)
    }
    
    public var unique: [Element] {
        var unique: [Element] = []
        var set: Set<Element> = []
        for i in self where !set.contains(i) {
            unique.append(i)
            set.insert(i)
        }
        return unique
    }
}

extension RandomAccessCollection {
    public func get(_ index: Index) -> Element? {
        if index >= startIndex, index < endIndex {
            return self[index]
        }
        return nil
    }
}

extension Array {
    public func indexes(where checker: (Element) -> Bool) -> [Int] {
        enumerated().compactMap {
            checker($0.element) ? $0.offset : nil
        }
    }
}
