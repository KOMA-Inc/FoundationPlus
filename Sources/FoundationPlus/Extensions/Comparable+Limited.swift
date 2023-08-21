public extension Comparable {
    func limited(min: Self, max: Self) -> Self {
        if self < min {
            return min
        } else if self > max {
            return max
        }
        return self
    }
}
