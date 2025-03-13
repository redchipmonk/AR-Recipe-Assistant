//
//  IntPair.swift
//  AR-Recipe-Assistant
//
//  Created by Paul Han on 3/11/25.
//

import Foundation

public struct IntPair: Hashable {
    public var pair: (p: Int, q: Int)

    public init(p: Int, q: Int) {
        self.pair = (p, q)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(pair.p)
        hasher.combine(pair.q)
    }
}

public func == (left: IntPair, right: IntPair) -> Bool {
     return left.pair == right.pair
}
