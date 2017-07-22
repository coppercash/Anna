//
//  Builder.swift
//  Anna
//
//  Created by William on 20/05/2017.
//
//

import Foundation

extension Dictionary {
    mutating func merge(with dictionary: Dictionary) {
        dictionary.forEach { updateValue($1, forKey: $0) }
    }
    
    func merged(with another: Dictionary) ->Dictionary {
        var merged = self
        merged.merge(with: another)
        return merged
    }
}

extension Array {
    mutating func merge(with another: Array) {
        self += another
    }
    
    func merged(with another: Array) ->Array {
        return self + another
    }
}
