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
EasyTrackerConfigurator {
    typealias
    Host = EasyManager
    unowned let
    host :Host
    init(host :Host) {
        self.host = host
    }
    
    public typealias
    Tracker = EasyTracker
    var
    trackers = [String:Tracker]()
    public
    subscript(key :String) ->Tracker? {
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

public protocol
EasyTrackerCollection {
    typealias
    Tracker = EasyTracker
    subscript(key :String) ->Tracker? { get }
}

extension
EasyTrackerConfigurator : EasyTrackerCollection {}

public protocol
EasyTrackerBuilding : class {
    var
    trackersBuffer :[Tracker]? { get set }
    typealias
        Tracker = EasyTracker
    @discardableResult func
        tracker(_ tracker :Tracker) ->Self
    
    typealias
        Trackers = EasyTrackerCollection
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
