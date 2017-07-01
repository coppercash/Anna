//
//  ANAMethod.swift
//  Anna
//
//  Created by William on 08/07/2017.
//
//

import Foundation

class
    ANAMethodPointBuilder :
    NSObject,
    ANAMethodPointBuilding
{
    typealias
        Proto = EasyMethodPointBuilder
    let
    proto :Proto
    init(_ proto :Proto) {
        self.proto = proto
    }
    
    var
    selector: (Selector) -> ANAMethodPointBuilding {
        return { [unowned self] (selector) in
            self.proto.selectors.append(selector)
            return self
        }
    }

    var
    set: (String, Any?) -> ANAMethodPointBuilding {
        return { [unowned self] (key, value) in
            self.proto.buffer.set(key, value)
            return self
        }
    }


//    var point: (ANAMethodPointBuildup?) -> ANAClassPointBuilding {
//        return { [unowned self] (buildup) in
//            let
//            builder = ANAMethodPointBuilder(ANAMethodPointBuilder.Proto(trackers: self.proto.trackers))
//            buildup(builder)
//            self.proto.append(builder)
//            return self
//        }
//    }
}
