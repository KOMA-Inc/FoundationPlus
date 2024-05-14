public struct Tuple2<A, B> {

    public let a: A
    public let b: B

    public var tuple: (A, B) {
        (a, b)
    }

    public init(_ a: A, _ b: B) {
        self.a = a
        self.b = b
    }

    public init(_ tuple: (A, B)) {
        self.init(tuple.0, tuple.1)
    }
}

extension Tuple2: Equatable where A: Equatable, B: Equatable { }

public extension Tuple2 {

    func map<C, D>(_ transformA: (A) -> C, _ transformB: (B) -> D) -> Tuple2<C, D> {
        Tuple2<C, D>(transformA(a), transformB(b))
    }
}

public extension Tuple2 {

    func swapped() -> Tuple2<B, A> {
        Tuple2<B, A>(b, a)
    }
}
