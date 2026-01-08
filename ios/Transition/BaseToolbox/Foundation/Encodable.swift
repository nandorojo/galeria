import Foundation

extension Encodable {
    public func write(to url: URL) throws {
        try JSONEncoder().encode(self).write(to: url)
    }
    
    public var jsonString: String {
        return String(data: try! JSONEncoder().encode(self), encoding: .utf8)!
    }
    
    public var prettyJsonString: String {
        let data = try! JSONSerialization.data(withJSONObject: jsonDictionary, options: .prettyPrinted)
        return String(data: data, encoding: .utf8)!
    }
    
    public var jsonDictionary: [String: Any] {
        let data = try! JSONEncoder().encode(self)
        return try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
    }
    
    public var jsonData: Data? {
        return try? JSONEncoder().encode(self)
    }
}
