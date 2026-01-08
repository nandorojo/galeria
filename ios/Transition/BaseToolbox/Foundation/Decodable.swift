import Foundation

extension Decodable {
    public static func read(from url: URL) throws -> Self {
        try JSONDecoder().decode(self, from: Data(contentsOf: url))
    }
}
