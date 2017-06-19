//
//  Configuration.swift
//  Anna
//
//  Created by William on 17/06/2017.
//
//

import Foundation

public protocol
EasyPointDefaults {
    typealias
        Payload = Dictionary<String, Any>
    var
    payload :Payload? { get }
    typealias
        Tracker = EasyTracker
    var
    trackers :[Tracker] { get }
}

public protocol
EasyConfiguration {
    typealias
        PointDefaults = EasyPointDefaults 
    var pointDefaults :PointDefaults { get }
}
