/// UnionFind is a data structure that can keep track of a set of elements partitioned into a number of disjoint (non-overlapping) subsets
public struct UnionFind<T: Hashable> {

    private var index = [T: Int]()
    private var parent = [Int]()
    public var size = [Int]()

    /// Creates an empty ``UnionFind``
    public init() { }

    /// Creates an ``UnionFind`` filled with elements
    /// - Parameter elements: elements to fill the ``UnionFind`` with
    public init(with elements: Set<T>) {
        elements.forEach {
            add($0)
        }
    }

    private mutating func setByIndex(_ index: Int) -> Int {
        if parent[index] == index {
            return index
        } else {
            parent[index] = setByIndex(parent[index])
            return parent[index]
        }
    }
}

public extension UnionFind {

    /// Adds the element to UnionFind
    mutating func add(_ element: T) {
        index[element] = parent.count
        parent.append(parent.count)
        size.append(1)
    }

    mutating func setOfElement(_ element: T) -> Int? {
        index[element].map { setByIndex($0) }
    }

    mutating func inSameSet(_ firstElement: T, and secondElement: T) -> Bool {
        if let firstSet = setOfElement(firstElement),
           let secondSet = setOfElement(secondElement) {
            return firstSet == secondSet
        } else {
            return false
        }
    }

    @discardableResult
    mutating func union(_ firstElement: T, and secondElement: T) -> Bool {
        guard let firstSet = setOfElement(firstElement),
              let secondSet = setOfElement(secondElement),
              firstSet != secondSet else {
            return false
        }

        if size[firstSet] < size[secondSet] {
            parent[firstSet] = secondSet
            size[secondSet] += size[firstSet]
        } else {
            parent[secondSet] = firstSet
            size[firstSet] += size[secondSet]
        }

        return true
    }
}
