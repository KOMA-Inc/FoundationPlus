/// References:
/// http://surl.li/eyykd
/// https://github.com/apple/swift/issues/46668

@inlinable
public func == <A: Equatable, B: Equatable>(lhs: (A, B), rhs: (A, B)) -> Bool {
    guard lhs.0 == rhs.0 else { return false }
    /*tail*/ return(
        lhs.1
    ) == (
        rhs.1
    )
}

@inlinable
public func != <A: Equatable, B: Equatable>(lhs: (A, B), rhs: (A, B)) -> Bool {
    !(lhs == rhs)
}

@inlinable
public func == <A: Equatable, B: Equatable>(lhs: [(A, B)], rhs: [(A, B)]) -> Bool {
    guard lhs.count == rhs.count else { return false }
    for (idx, lElement) in lhs.enumerated() {
        guard lElement == rhs[idx] else {
            return false
        }
    }
    return true
}

@inlinable
public func != <A: Equatable, B: Equatable>(lhs: [(A, B)], rhs: [(A, B)]) -> Bool {
    !(lhs == rhs)
}

@inlinable
public func == <A: Equatable, B: Equatable, C: Equatable>(lhs: (A, B, C), rhs: (A, B, C)) -> Bool {
    guard lhs.0 == rhs.0 else { return false }
    /*tail*/ return(
        lhs.1, lhs.2
    ) == (
        rhs.1, rhs.2
    )
}

@inlinable
public func != <A: Equatable, B: Equatable, C: Equatable>(lhs: (A, B, C), rhs: (A, B, C)) -> Bool {
    !(lhs == rhs)
}

@inlinable
public func == <A: Equatable, B: Equatable, C: Equatable>(lhs: [(A, B, C)], rhs: [(A, B, C)]) -> Bool {
    guard lhs.count == rhs.count else { return false }
    for (idx, lElement) in lhs.enumerated() {
        guard lElement == rhs[idx] else {
            return false
        }
    }
    return true
}

@inlinable
public func != <A: Equatable, B: Equatable, C: Equatable>(lhs: [(A, B, C)], rhs: [(A, B, C)]) -> Bool {
    !(lhs == rhs)
}
