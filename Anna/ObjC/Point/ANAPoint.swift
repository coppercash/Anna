//
//  ANAPoint.swift
//  Anna
//
//  Created by William on 14/07/2017.
//
//

import Foundation

public class
    ANAPointBuilder :
    NSObject,
    ANAPointBuilding
{
    typealias
        Proto = EasyPointBuilder
    let
    proto :Proto
    init(_ proto :Proto) {
        self.proto = proto
        self.availableTrackers = ObjCTrackerCollection(proto.trackers)
    }

    public var
    set: (String, Any?) -> ANAPointBuilding {
        return { [unowned self] (key, value) in
            self.proto.set(key, value)
            return self
        }
    }

    public var
    point: (ANAPointBuildup?) -> ANAPointBuilding {
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
    
    public var
    equal: (String, NSObject) -> ANAPointBuilding {
        return { [unowned self] (key, value) in
            self.proto.when(key, equal: value)
            return self
        }
    }

    public var
    tracker: (ANATracker) -> ANAPointBuilding {
        return { [unowned self] (tracker) in
            self.proto.tracker(SwiftEasyTracker(tracker))
            return self
        }
    }
    
    public let
    availableTrackers: ANATrackerCollection
}
