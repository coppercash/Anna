//
//  Tracker.swift
//  Anna
//
//  Created by William on 11/05/2017.
//
//

import Foundation

public protocol
EasyTracking {
    typealias
        Event = Anna.EventBeing
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

public protocol
EasyTrackerConfiguring : class {
    typealias
        Tracker = Anna.Tracking
    subscript(key :AnyHashable) ->Tracker? { set get }
    var
    defaults :[Tracker]? { set get }
}

public protocol
EasyTrackerCollecting {
    typealias
        Tracker = Anna.Tracking
    subscript(key :AnyHashable) ->Tracker? { get }
}

class
    EasyTrackerConfigurator :
    EasyTrackerConfiguring,
    EasyTrackerCollecting
{
    typealias
    Host = EasyManager
    unowned let
    host :Host
    init(host :Host) {
        self.host = host
    }
    
    public typealias
    Tracker = EasyTracking
    var
    trackers = [AnyHashable : Tracker]()
    public
    subscript(key :AnyHashable) ->Tracker? {
        get {
            var
            tracker :Tracker? = nil
            host.configQueue.sync {
                tracker = self.trackers[key]
            }
            return tracker
        }
        set {
            host.configQueue.async(flags: .barrier) {
                self.trackers[key] = newValue
            }
        }
    }
    
    public var
    defaults :[Tracker]? {
        get {
            var
            trackers :[Tracker]?
            host.configQueue.sync {
                trackers = host.root.trackers
            }
            return trackers
        }
        set {
            host.configQueue.async(flags: .barrier) {
                self.host.root.trackers = newValue
            }
        }
    }
}

protocol
EasyTrackerBuilding : class {
    var
    trackersBuffer :[Tracker]? { get set }
    var
    overridesTrackers :Bool { get set }
    
    typealias
        Tracker = EasyTracking
    @discardableResult func
        tracker(_ tracker :Tracker) ->Self
    @discardableResult func
        trackers<Trackers>(_ trackers :Trackers) ->Self
        where Trackers : Sequence, Trackers.Iterator.Element == Tracker
    
    typealias
        Trackers = EasyTrackerCollecting
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
    
    @discardableResult public func
        trackers<Trackers>(_ trackers :Trackers) ->Self
        where Trackers : Sequence, Trackers.Iterator.Element == Tracker {
            trackersBuffer = Array(trackers)
            overridesTrackers = true
            return self
    }
}
