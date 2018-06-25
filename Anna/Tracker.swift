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
    @objc(manager:didSendResult:)
    func
        manager(
        _ manager :Manager,
        didSend result :Any
    )
}
