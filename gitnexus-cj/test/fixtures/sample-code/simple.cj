package demo

import std.collection.*

public class Foo <: Bar {
    let x: Int64 = 0

    public init() {}

    public func hello(a: Int64): Unit {
        print(a)
    }
}

public func top(): Int64 {
    return 0
}
