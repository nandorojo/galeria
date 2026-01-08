import Foundation

extension NSRange {
    public func offset(by: Int) -> NSRange {
        NSRange(location: location + by, length: length)
    }
    
    public func contains(_ range: NSRange) -> Bool {
        lowerBound <= range.lowerBound && upperBound >= range.upperBound
    }
    
    public func overlaps(_ range: NSRange) -> Bool {
        range.intersection(self)?.length ?? 0 > 0
    }
    
    public func isAdjacent(to range: NSRange) -> Bool {
        lowerBound == range.upperBound || upperBound == range.lowerBound
    }
}
