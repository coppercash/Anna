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
        receiveAnalyticsEvent(
        _ event :Event,
        dispatchedBy manager :Manager
    )
}
