//
//  ANAPrefix.swift
//  Anna
//
//  Created by William on 01/07/2017.
//
//

import Foundation

public class
    ANAPrefix :
    NSObject,
    ANAPrefixing
{
    unowned let
    target :ANAAnalyzable
    let
    selector :Selector
    public init
    (
        target :ANAAnalyzable,
        selector :Selector
        ) {
        self.target = target
        self.selector = selector
    }
    
    public var
    analyze: (() -> Void) {
        return { [unowned self] in
            let
            seed = ANAEventSeed(
                class: type(of: self.target),
                selector: self.selector,
                payload: nil
            )
            self.target.ana_analyticsManager().dispatchEvent(withSeed: seed)
        }
    }
}
