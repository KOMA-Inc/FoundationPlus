public extension Comparable {
    func limited(min: Self, max: Self) -> Self {
        if self < min {
            return min
        } else if self > max {
            return max
        }
        return self
    }

    func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}
