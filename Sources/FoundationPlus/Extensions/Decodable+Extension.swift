import Foundation

public extension Decodable {
    static func decodeFrom(
        jsonData: Data,
        decoder: JSONDecoder = .init()
    ) throws -> Self {
        try decoder.decode(Self.self, from: jsonData)
    }

    static func decodeFrom(
        jsonString: String,
        decoder: JSONDecoder = .init()
    ) throws -> Self {
        let data = jsonString.data(using: .utf8)
        return try decodeFrom(jsonData: data!, decoder: decoder)
    }
}
