public extension Encodable {
    func encoded(encoder: JSONEncoder = JSONEncoder()) throws -> Data {
        try encoder.encode(self)
    }

    func encodedString(
        encoder: JSONEncoder = JSONEncoder(),
        using encoding: String.Encoding = .utf8
    ) throws -> String {
        let data = try encoded(encoder: encoder)
        let string = String(data: data, encoding: encoding)
        return string!
    }
}
