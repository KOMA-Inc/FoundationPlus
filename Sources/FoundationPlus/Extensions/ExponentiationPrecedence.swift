import Darwin

precedencegroup ExponentiationPrecedence {
    associativity: right
    higherThan: MultiplicationPrecedence
}

infix operator **: ExponentiationPrecedence

public func **(num: Double, power: Double) -> Double {
    pow(num, power)
}

public func **(num: Int, power: Int) -> Int {
    Int(pow(Double(num), Double(power)))
}

public func **(_ base: Float, _ exp: Float) -> Float {
    pow(base, exp)
}
