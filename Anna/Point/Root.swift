//
//  PointSet.swift
//  Anna
//
//  Created by William on 10/06/2017.
//
//

import Foundation

public class
EasyRootPoint : EasyBasePoint {
    typealias
        Child = EasyClassPoint
    var
    children :[Child.Class: Child] = Dictionary<Child.Class, Child>()
    
    init(trackers :[Tracker], payload :Payload? = nil) {
        super.init(trackers: trackers, payload: payload);
    }
}

extension
EasyRootPoint : EasyPayloadNode {
    var
    parentNode: EasyPayloadNode? {
        return nil
    }
}

extension
EasyRootPoint : EasyEventMatching {
    func
        points(match event :EasyEventMatching.Event) ->[EasyEventMatching.Point]? {
        return classPoint(for: event.cls)?.points(match: event)
    }
}

extension
EasyRootPoint {
    typealias
        Sender = EasyAnalyzable
    func classPoint(for cls :Sender.Type) ->Child? {
        return children[String(describing: cls)]
    }
    func setClassPoint(_ classPoint :Child, for cls :Sender.Type) {
        children[String(describing: cls)] = classPoint
    }
}
