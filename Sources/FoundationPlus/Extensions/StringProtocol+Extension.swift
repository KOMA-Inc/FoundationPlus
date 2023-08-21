public extension StringProtocol {
    subscript(offset: Int) -> Character {
        self[index(startIndex, offsetBy: offset)]
    }

    subscript(bounds: Range<Int>) -> SubSequence {
        let start = startIndex(offsetBy: bounds.lowerBound)
        let end = startIndex(offsetBy: bounds.upperBound)
        return self[start..<end]
    }

    subscript(bounds: ClosedRange<Int>) -> SubSequence {
        let start = startIndex(offsetBy: bounds.lowerBound)
        let end = startIndex(offsetBy: bounds.upperBound)
        return self[start...end]
    }

    subscript(bounds: PartialRangeFrom<Int>) -> SubSequence {
        let start = startIndex(offsetBy: bounds.lowerBound)
        let end = endIndex(offsetBy: 0)
        return self[start...end]
    }

    subscript(bounds: PartialRangeUpTo<Int>) -> SubSequence {
        let start = startIndex(offsetBy: 0)
        let end = startIndex(offsetBy: bounds.upperBound)
        return self[start..<end]
    }

    subscript(bounds: PartialRangeThrough<Int>) -> SubSequence {
        let start = startIndex(offsetBy: 0)
        let end = startIndex(offsetBy: bounds.upperBound)
        return self[start...end]
    }

    func startIndex(offsetBy value: Int) -> Self.Index {
        index(startIndex, offsetBy: value)
    }

    func endIndex(offsetBy value: Int) -> Self.Index {
        index(endIndex, offsetBy: -(value + 1))
    }
}
