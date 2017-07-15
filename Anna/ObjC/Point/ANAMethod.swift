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
        self.availableTrackers = ObjCTrackerCollection(proto.trackers)
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
            self.proto.set(key, value)
            return self
        }
    }

    public var
    point: (ANAPointBuildup?) -> ANAMethodPointBuilding {
        return { [unowned self] (buildup) in
            let
            builder = ANAPointBuilder(
                ANAPointBuilder.Proto(
                    trackers: self.proto.trackers
                )
            )
            buildup!(builder)
            self.proto.append(builder.proto)
            return self
        }
    }
    
    var
    tracker: (ANATracker) -> ANAMethodPointBuilding {
        return { [unowned self] (tracker) in
            self.proto.tracker(SwiftEasyTracker(tracker))
            return self
        }
    }
    
    public var
    trackers: ([ANATracker]) -> ANAMethodPointBuilding {
        return { [unowned self] (trackers) in
            self.proto.trackers(trackers.map { SwiftEasyTracker($0) })
            return self
        }
    }
    
    let availableTrackers: ANATrackerCollection
}

