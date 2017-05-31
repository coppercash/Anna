//
//  Tracker.swift
//  Anna
//
//  Created by William on 11/05/2017.
//
//

import Foundation

public protocol
Trackable {
    
}

public protocol
Tracker {
    func
        receive(
        event :Event,
        with point :Point,
        dispatchedBy manager :Manager
    )
}
