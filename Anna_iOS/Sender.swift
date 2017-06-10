//
//  Sender.swift
//  Anna
//
//  Created by William on 10/06/2017.
//
//

import Foundation

public protocol
EasySender {
    typealias
        Prefix = EasyPrefix
    typealias
        Manager = EasyManager
    var
    ana :Prefix { get }
    var
    analysisManager :Manager { get }
}

public extension
EasySender {
    var ana :Prefix {
        return Prefix(target: self)
    }
}
