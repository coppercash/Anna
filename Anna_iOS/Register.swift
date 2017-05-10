//
//  Register.swift
//  Anna
//
//  Created by William on 22/04/2017.
//
//

import Foundation

public protocol Registrar {
    @discardableResult
    func point(_ :PointBuilding) ->Self
}

public protocol Registrant {
    static func registerPoints(with registrar :Registrar)
}
