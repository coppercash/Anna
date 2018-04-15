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
    ANAPrefixing,
    BuilderParenting
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
        return ANAPrefix._analyze(self)
    }
    
    func
        _analyze() {
        let
        seed :ANAEventSeed
        if let builder = eventSeed {
            builder.cls = type(of: target)
            builder.selector = selector
            seed = try! builder.eventSeed()
        }
        else {
            seed = ANAEventSeed(
                class: type(of: target),
                selector: selector,
                payload: nil
            )
        }
        target.ana_analyticsManager().dispatchEvent(with: seed)
    }
    
    public var
    event_: ANAEventSeedBuilding {
        return ANAEventSeedBuilder(parent: self)
    }
    
    typealias
        EventSeed = ANAEventSeedBuilder
    var
    eventSeed :EventSeed? = nil
    func
        close(child :Any) {
        if let seed = child as? EventSeed {
            self.eventSeed = seed
        }
    }
    
    public var
    analyst :ANAAnalyst {
        return target.ana_analyst()
    }
}
