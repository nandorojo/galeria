// Range+Extensions.swift
// Copyright © 2020 Noto. All rights reserved.

import Foundation

extension Range where Element: Numeric {
    public func offset(by: Element) -> Range<Element> {
        (lowerBound + by)..<(upperBound + by)
    }
}

extension Range where Element: Strideable {
    public func contains(_ range: Range<Element>) -> Bool {
        lowerBound <= range.lowerBound && upperBound >= range.upperBound
    }
    
    public func union(_ range: Range<Element>) -> Range<Element> {
        Swift.min(lowerBound, range.lowerBound)..<Swift.max(upperBound, range.upperBound)
    }
    
    public func touching(range: Range<Element>) -> Bool {
        (upperBound >= range.upperBound && lowerBound <= range.upperBound)  // overlap range.upperBound
        || (lowerBound <= range.lowerBound && upperBound >= range.lowerBound)  // overlap range.lowerBound
        || (lowerBound <= range.lowerBound && upperBound >= range.upperBound)  // contained in self
        || (lowerBound >= range.lowerBound && upperBound <= range.upperBound)  // contained in range
    }
    
    public func intersection(_ range: Range<Element>) -> Range<Element>? {
        guard overlaps(range) else { return nil }
        return Swift.max(lowerBound, range.lowerBound)..<Swift.min(upperBound, range.upperBound)
    }
    
    public func rangesByRemoving(_ range: Range<Element>) -> [Range] {
        var results: [Range<Element>] = []
        if range.lowerBound > lowerBound {  // lower half
            results.append(lowerBound..<range.lowerBound)
        }
        if upperBound > range.upperBound {  // upper half
            results.append(range.upperBound..<upperBound)
        }
        return results
    }
}
