public extension Dictionary {
    var removingOptionals: Self {
        compactMapValues { $0 }
    }

    func addIfPresent(_ value: Value?, for key: Key) -> Self {
        var dict = self
        if let value {
            dict[key] = value
        }
        return dict
    }
}
