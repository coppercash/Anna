//
//  Register.swift
//  Anna
//
//  Created by William on 22/04/2017.
//
//

import Foundation

public protocol
EasyRegistrationRecording {
    typealias
        PointBuilder = EasyMethodPointBuilder
    @discardableResult func
        point(_ :PointBuilder.Buildup) ->Self
    typealias
        SuperClass = EasyRegistering
    @discardableResult func
        superClass(_ cls :SuperClass.Type) ->Self
}

public protocol
EasyRegistering {
    typealias
        Registrar = EasyRegistrationRecording
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
