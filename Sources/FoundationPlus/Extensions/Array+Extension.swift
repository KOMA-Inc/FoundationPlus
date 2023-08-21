public extension Array where Element: Hashable {
    var unique: Self {
        Array(Set(self))
    }

    func hasSameElements<C>(as collection: C) -> Bool where C: Collection, C.Element == Element {
        Set(self).symmetricDifference(Set(collection)).isEmpty
    }
}

public extension Array {

    subscript(safe index: Int) -> Element? {
        indices ~= index ? self[index] : nil
    }

    subscript(safe index: Int, default: Element) -> Element {
        indices ~= index ? self[index] : `default`
    }

    /// Returns a slice of the array in a safe matter
    ///
    /// ```
    /// let array = [1, 2, 3, 4, 5]
    /// array[safe: 0..<5] == [1, 2, 3, 4, 5]
    /// array[safe: 5..<6] == []
    /// ```
    subscript(safe bounds: Range<Int>) -> ArraySlice<Element> {
        guard indices ~= bounds.lowerBound, indices ~= bounds.upperBound - 1 else { return [] }
        return self[bounds.lowerBound..<bounds.upperBound]
    }

    /// Returns a slice of the array in a safe matter
    ///
    /// ```
    /// let array = [1, 2, 3, 4, 5]
    /// array[safe: 0...4] == [1, 2, 3, 4, 5]
    /// array[safe: 4...5] == []
    /// ```
    subscript(safe bounds: ClosedRange<Int>) -> ArraySlice<Element> {
        guard indices ~= bounds.lowerBound, indices ~= bounds.upperBound else { return [] }
        return self[bounds.lowerBound...bounds.upperBound]
    }

    /// Returns a slice of the array in a safe matter
    ///
    /// ```
    /// let array = [1, 2, 3, 4, 5]
    /// array[safe: 2...] == [3, 4, 5]
    /// array[safe: 5...] == []
    /// ```
    subscript(safe bounds: PartialRangeFrom<Int>) -> ArraySlice<Element> {
        guard indices ~= bounds.lowerBound else { return [] }
        return self[bounds.lowerBound..<endIndex]
    }

    /// Returns a slice of the array in a safe matter
    ///
    /// ```
    /// let array = [1, 2, 3, 4, 5]
    /// array[safe: ..<5] == [1, 2, 3, 4, 5]
    /// array[safe: ..<6] == []
    /// ```
    subscript(safe bounds: PartialRangeUpTo<Int>) -> ArraySlice<Element> {
        guard indices ~= bounds.upperBound - 1 else { return [] }
        return self[..<bounds.upperBound]
    }

    /// Returns a slice of the array in a safe matter
    ///
    /// ```
    /// let array = [1, 2, 3, 4, 5]
    /// array[safe: ...4] == [1, 2, 3, 4, 5]
    /// array[safe: ...5] == []
    /// ```
    subscript(safe bounds: PartialRangeThrough<Int>) -> ArraySlice<Element> {
        guard indices ~= bounds.upperBound else { return [] }
        return self[...bounds.upperBound]
    }

    init(repeatingCallback repeatedValue: () -> Element, count: Int) {
        self.init()
        reserveCapacity(count)
        while self.count < count {
            append(repeatedValue())
        }
    }
}

public extension Array where Element == String {
    /// Merges two array by appending each string from input array to each string from original array
    ///
    /// ```
    /// ["a", "b", "c"].merge(with: ["1", "2"] == ["a1", "a2", "b1", "b2", "c1", "c2"]
    /// [].merge(with: ["1", "2"] == ["1", "2"]
    /// ["a", "b", "c"].merge(with: [] == ["a", "b", "c"]
    /// ```
    func merge(with otherArray: Self) -> Self {
        if isEmpty { return otherArray }
        if otherArray.isEmpty { return self }
        return flatMap { a in
            otherArray.map { b in
                a + b
            }
        }
    }
}
