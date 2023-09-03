public extension Collection {
    var isFilled: Bool {
        !isEmpty
    }

    var nilIfEmpty: Self? {
        isFilled ? self : nil
    }
}

public extension Collection where Element: Hashable {
    var occurrences: [Element: Int] {
        reduce(into: [:]) { counts, element in
            counts[element, default: 0] += 1
        }
    }

    var areUnique: Bool {
        count == Set(self).count
    }
}
