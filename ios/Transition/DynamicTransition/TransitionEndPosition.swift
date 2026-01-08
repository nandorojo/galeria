import Foundation

public enum TransitionEndPosition {
    case dismissed
    case presented

    public var reversed: Self {
        switch self {
        case .dismissed:
            return .presented
        case .presented:
            return .dismissed
        }
    }
}
