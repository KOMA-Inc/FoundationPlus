import FoundationPlus

/// A max heap is a binary tree where every node has a value greater than or equal to its children
public struct MaxHeap<Element>: ExpressibleByArrayLiteral where Element: Comparable {

    public init(_ elements: [Element]) {
        for element in elements {
            add(element)
        }
    }

    public init(arrayLiteral elements: Element...) {
        self.init(elements)
    }

    private var items: [Element] = []

    private func getLeftChildIndex(_ parentIndex: Int) -> Int {
        2 * parentIndex + 1
    }

    private func getRightChildIndex(_ parentIndex: Int) -> Int {
        2 * parentIndex + 2
    }

    private func getParentIndex(_ childIndex: Int) -> Int {
        (childIndex - 1) / 2
    }

    private func hasLeftChild(_ index: Int) -> Bool {
        getLeftChildIndex(index) < items.count
    }
    private func hasRightChild(_ index: Int) -> Bool {
        getRightChildIndex(index) < items.count
    }
    private func hasParent(_ index: Int) -> Bool {
        getParentIndex(index) >= 0
    }


    private func leftChild(_ index: Int) -> Element {
        items[getLeftChildIndex(index)]
    }

    private func rightChild(_ index: Int) -> Element {
        items[getRightChildIndex(index)]
    }

    private func parent(_ index: Int) -> Element {
        items[getParentIndex(index)]
    }

    mutating private func swap(indexOne: Int, indexTwo: Int) {
        let placeholder = items[indexOne]
        items[indexOne] = items[indexTwo]
        items[indexTwo] = placeholder
    }

    mutating private func heapifyUp() {
        var index = items.count - 1
        while hasParent(index) && parent(index) < items[index] {
            swap(indexOne: getParentIndex(index), indexTwo: index)
            index = getParentIndex(index)
        }
    }

    mutating private func heapifyDown() {
        var index = 0
        while hasLeftChild(index) {
            var greaterChildIndex = getLeftChildIndex(index)
            if hasRightChild(index) && rightChild(index) > leftChild(index) {
                greaterChildIndex = getRightChildIndex(index)
            }

            if items[index] > items[greaterChildIndex] {
                break
            } else {
                swap(indexOne: index, indexTwo: greaterChildIndex)
            }
            index = greaterChildIndex
        }
    }
}

public extension MaxHeap {

    /// A Boolean value indicating whether the heap is empty
    var isEmpty: Bool {
        items.isEmpty
    }

    /// Total number of elements in the MinHeap
    var count: Int {
        items.count
    }

    /// Returns an element by index
    subscript(index: Int) -> Element {
        items[index]
    }

    /// Returns an element by index if exists
    subscript(safe index: Int) -> Element? {
        items[safe: index]
    }

    /// Returns the first element
    func peek() -> Element {
        items[0]
    }

    /// Returns and removes the first element
    @discardableResult
    mutating func poll() -> Element {
        let item = items[0]
        items[0] = items[items.count - 1]
        heapifyDown()
        items.removeLast()
        return item
    }

    /// Adds an element
    mutating func add(_ item: Element) {
        items.append(item)
        heapifyUp()
    }
}
