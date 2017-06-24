//
//  Tracker.swift
//  Anna
//
//  Created by William on 11/05/2017.
//
//

import Foundation

public protocol
EasyTracker {
    typealias
        Event = EasyEvent
    typealias
        Manager = EasyManager
    func
        receive(
        analyticsEvent event :Event,
        dispatchedBy manager :Manager
    )
    func
        receive(
        analyticsError error :Error,
        dispatchedBy manager :Manager
    )
}

public class
EasyTrackerCollection {
    let
    queue :DispatchQueue
    init(queue :DispatchQueue) {
        self.queue = queue
    }
    
    public typealias
    Tracker = EasyTracker
    var
    trackers = [String:Tracker]()
    public
    subscript(key :String) ->Tracker? {
        get {
            return trackers[key]
        }
        set {
            
            trackers[key] = newValue
        }
    }
}

public protocol
EasyImmutableTrackerCollection {
    typealias
    Tracker = EasyTracker
    subscript(key :String) ->Tracker? { get }
}

extension
EasyTrackerCollection : EasyImmutableTrackerCollection {}

public protocol
EasyTrackerBuilding : class {
    var
    trackersBuffer :[Tracker]? { get set }
    typealias
        Tracker = EasyTracker
    @discardableResult func
        tracker(_ tracker :Tracker) ->Self
    
    typealias
        Trackers = EasyImmutableTrackerCollection
    var
    trackers :Trackers { get }
}

extension
EasyTrackerBuilding {
    @discardableResult public func
        tracker(_ tracker :Tracker) ->Self {
        if trackersBuffer == nil {
            trackersBuffer = [Tracker]()
        }
        trackersBuffer!.append(tracker)
        return self
    }
}
