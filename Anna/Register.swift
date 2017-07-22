//
//  Register.swift
//  Anna
//
//  Created by William on 22/04/2017.
//
//

import Foundation

public protocol
EasyRegistrationRecording : EasyClassPointBuilding {
}

public protocol
EasyRegistering {
    typealias
        Registrar = RegistrationRecording
    static func
        registerAnalyticsPoints(with registrar :Registrar)
}

protocol
EasyRegisteringCarrying {
    typealias
        Registrant = EasyRegistering
    var
    registrant : Registrant.Type { get }
}
