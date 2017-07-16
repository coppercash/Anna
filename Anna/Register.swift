//
//  Register.swift
//  Anna
//
//  Created by William on 22/04/2017.
//
//

import Foundation

public protocol
EasyRegistrar {
    typealias
        PointBuilder = EasyMethodPointBuilder
    @discardableResult func
        point(_ :PointBuilder.Buildup) ->Self
    typealias
        SuperClass = EasyRegistrant
    @discardableResult func
        superClass(_ cls :SuperClass.Type) ->Self
}

public protocol
EasyRegistrant {
    typealias
        Registrar = EasyRegistrar
    static func
        registerAnalyticsPoints(with registrar :Registrar)
}

protocol
EasyRegistrantCarrying {
    typealias
        Registrant = EasyRegistrant
    var
    registrant : Registrant.Type { get }
}
