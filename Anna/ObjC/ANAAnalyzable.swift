//
//  ANAAnalyzable.swift
//  Anna
//
//  Created by William on 12/07/2017.
//
//

import Foundation

extension
NSObject {
    public func
        ana_context() ->(Selector)->ANAPrefixing {
        return { [unowned self] (selector) in
            return ANAPrefix(
                target: self as! ANAAnalyzable,
                selector: selector
            )
        }
    }

    public func
        ana_analyticsManager() ->ANAEventDispatching {
        return ANAManager.sharedManager
    }
}
