public func +<Element>(
    lhs: Array<Element>,
    rhs: Element
) -> Array<Element> {
    lhs + CollectionOfOne(rhs)
}

public func +<Element>(
    lhs: Element,
    rhs: Array<Element>
) -> Array<Element> {
    CollectionOfOne(lhs) + rhs
}
