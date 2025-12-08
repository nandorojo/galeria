import Foundation

extension URL {
    public static let temporary = URL(fileURLWithPath: NSTemporaryDirectory())
    public static let document = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    public static let applicationSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
}
