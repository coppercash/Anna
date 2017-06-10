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
        PointBuilder = EasyPointBuilder
    @discardableResult
    func point(_ :PointBuilder.Buildup) ->Self
}

public protocol
EasyRegistrant {
    typealias
        Registrar = EasyRegistrar
    static func
        registerAnalysisPoints(with registrar :Registrar)
}
