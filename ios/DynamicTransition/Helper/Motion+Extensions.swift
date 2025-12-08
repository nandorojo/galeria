//
//  Motion+Extensions.swift
//  
//
//  Created by Luke Zhao on 10/14/23.
//

import Motion

extension SupportedSIMD where Scalar: SupportedScalar {
    func distance(between other: Self) -> Scalar {
        var result = Scalar.zero
        for i in 0..<scalarCount {
            result += abs(self[i] - other[i])
        }
        return result
    }
    func createClampingRange(other: Self) -> ClosedRange<Self> {
        var minValue = Self(repeating: 0)
        var maxValue = Self(repeating: 0)
        for i in 0..<scalarCount {
            minValue[i] = Swift.min(self[i], other[i])
            maxValue[i] = Swift.max(self[i], other[i])
        }
        return minValue...maxValue
    }
}

extension SIMDRepresentable where SIMDType.Scalar: SupportedScalar {
    func distance(between other: Self) -> SIMDType.Scalar {
        simdRepresentation().distance(between: other.simdRepresentation())
    }
}
