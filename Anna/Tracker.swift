//
//  Tracker.swift
//  Anna
//
//  Created by William on 11/05/2017.
//
//

import Foundation

@objc(ANATracking)
public protocol
    Tracking
{
    @objc(receiveAnalyticsResult:dispatchedByManager:)
    func
        receive(
        analyticsResult :Any,
        dispatchedBy manager :Manager
    )
    @objc(receiveAnalyticsError:dispatchedByManager:)
    func
        receive(
        analyticsError :Error,
        dispatchedBy manager :Manager
    )
}
