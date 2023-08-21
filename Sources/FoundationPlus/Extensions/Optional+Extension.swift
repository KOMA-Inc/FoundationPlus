public extension Optional where Wrapped == String {
    var isEmpty: Bool {
        switch self {
        case let .some(string):
            return string.isEmpty
        case .none:
            return false
        }
    }

    var hasVisibleContent: Bool {
        switch self {
        case let .some(string):
            return string.hasVisibleContent
        case .none:
            return false
        }
    }

    var emptyIfNil: String {
        switch self {
        case let .some(string):
            return string
        case .none:
            return ""
        }
    }
}
