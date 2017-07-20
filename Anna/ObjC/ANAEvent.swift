//
//  ANAEvent.swift
//  Anna
//
//  Created by William on 01/07/2017.
//
//

import Foundation

class ObjCEvent :
    NSObject,
    ANAEventBeing
{
    typealias
        Proto = EasyEvent
    let
    proto :Proto
    init(_ proto :Proto) {
        self.proto = proto
    }
    
    subscript(key: NSCopying & NSObjectProtocol) -> Any? {
        return proto[key as! NSObject]
    }
}
