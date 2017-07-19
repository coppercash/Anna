//
//  ANATracker.swift
//  Anna
//
//  Created by William on 01/07/2017.
//
//

import Foundation

class ObjCTracker :
    NSObject,
    ANATracker
{
    typealias Proto = EasyTracker
    let proto :Proto
    init(_ proto :Proto) {
        self.proto = proto
    }
    
    func receiveAnalyticsEvent(
        _ event: ANAEvent,
        dispatchedBy manager: ANAManaging
        ) {
        proto.receive(
            analyticsEvent: (event as! ObjCEvent).proto,
            dispatchedBy: (manager as! ANAManager).proto
        )
    }
    
    func receiveAnalyticsError(
        _ error: Error,
        dispatchedBy manager: ANAManaging
        ) {
        proto.receive(
            analyticsError: error,
            dispatchedBy: (manager as! ANAManager).proto
        )
    }
}

class ObjCTrackerCollection :
    NSObject,
    ANATrackerCollection
{
    typealias Proto = EasyTrackerCollection
    let proto :Proto
    init(_ proto :Proto) {
        self.proto = proto
    }
    
    subscript(key: NSCopying & NSObjectProtocol) ->ANATracker? {
        get {
            if let tracker = proto[key as! NSObject] as? SwiftEasyTracker {
                return tracker.proto
            }
            else if let tracker = proto[key as! NSObject] {
                return ObjCTracker(tracker)
            }
            else {
                return nil
            }
        }
        set(tracker) {
        }
    }
}

class ObjCTrackerConfigurator :
    NSObject,
    ANATrackerConfigurator,
    ANATrackerCollection
{
    typealias Proto = EasyTrackerConfigurator
    let proto :Proto
    init(_ proto :Proto) {
        self.proto = proto
    }
    
    subscript(key: NSCopying & NSObjectProtocol) ->ANATracker? {
        get {
            if let tracker = proto[key as! NSObject] as? SwiftEasyTracker {
                return tracker.proto
            }
            else if let tracker = proto[key as! NSObject] {
                return ObjCTracker(tracker)
            }
            else {
                return nil
            }
        }
        set(tracker) {
            if let tracker = tracker {
                proto[key as! NSObject] = SwiftEasyTracker(tracker)
            }
            else {
                proto[key as! NSObject] = nil
            }
        }
    }

    var defaults: [ANATracker]? {
        get {
            return proto.defaults?.map { (tracker) -> ANATracker in
                if let tracker = tracker as? SwiftEasyTracker {
                    return tracker.proto
                }
                else {
                    return ObjCTracker(tracker)
                }
            }
        }
        set {
            guard let trackers = newValue else {
                proto.defaults = nil
                return
            }
            
            proto.defaults = trackers.map { (tracker) -> Proto.Tracker in
                return SwiftEasyTracker(tracker)
            }
        }
    }
}

class SwiftEasyTracker : EasyTracker {
    let proto :ANATracker
    init(_ proto :ANATracker) {
        self.proto = proto
    }
    
    func
        receive(
        analyticsEvent event :Event,
        dispatchedBy manager :Manager
        ) {
        proto.receiveAnalyticsEvent(
            ObjCEvent(event),
            dispatchedBy: ANAManager(manager)
        )
    }
    func
        receive(
        analyticsError error :Error,
        dispatchedBy manager :Manager
        ) {
        proto.receiveAnalyticsError(
            error,
            dispatchedBy: ANAManager(manager)
        )
    }
}
