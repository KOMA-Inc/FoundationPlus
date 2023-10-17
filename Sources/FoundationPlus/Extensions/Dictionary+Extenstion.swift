public extension Dictionary {
    var removingOptionals: Self {
        compactMapValues { $0 }
    }
}
