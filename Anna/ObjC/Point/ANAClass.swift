//
//  ANAClass.swift
//  Anna
//
//  Created by William on 07/07/2017.
//
//

import Foundation

class
ANAClassPoint : EasyClassPoint {
    
}

public class
    ANAClassPointBuilder :
    NSObject,
    ANAClassPointBuilding
{
    typealias
        Proto = EasyClassPointBuilder
    let
    proto :Proto
    init(_ proto :Proto) {
        self.proto = proto
    }

    public var
    point: (ANAMethodPointBuildup?) -> ANAClassPointBuilding {
        return { [unowned self] (buildup) in
            let
            builder = ANAMethodPointBuilder(
                ANAMethodPointBuilder.Proto(
                    trackers: self.proto.trackers
                )
            )
            buildup!(builder)
            self.proto.append(builder.proto)
            return self
        }
    }
}

extension
ANAClassPointBuilder {
    typealias
        Result = ANAClassPoint
    func
        build() throws ->Result {
        let children = Dictionary<
            EasyClassPoint.Child.Method,
            EasyClassPoint.Child
            >()
        return Result(
            trackers: nil,
            payload: nil,
            children: children
        )
    }
}
