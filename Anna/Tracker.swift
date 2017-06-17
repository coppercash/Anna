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
        Point = EasyPayloadCarrier
    typealias
        Manager = EasyManager
    func
        receiveAnalysisEvent(
        _ event :Event,
        with point :Point,
        dispatchedBy manager :Manager
    )
}
