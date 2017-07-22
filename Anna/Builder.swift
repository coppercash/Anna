//
//  Builder.swift
//  Anna
//
//  Created by William on 20/05/2017.
//
//

import Foundation

extension Dictionary {
    mutating func update(with dictionary: Dictionary) {
        dictionary.forEach { updateValue($1, forKey: $0) }
    }
    
    func updated(with another: Dictionary) ->Dictionary {
        var merged = self
        merged.update(with: another)
        return merged
    }
}

extension Array {
    mutating func update(with another: Array) {
        self += another
    }
    
    func updated(with another: Array) ->Array {
        return self + another
    }
}
