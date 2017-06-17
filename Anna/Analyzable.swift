//
//  Sender.swift
//  Anna
//
//  Created by William on 10/06/2017.
//
//

import Foundation

public protocol
EasyAnalyzable : EasyRegistrant {
    typealias
        Manager = EasyManager
    var
    analysisManager :Manager { get }
    typealias
        Prefix = EasyPrefix
    var
    ana :Prefix { get }
}

public extension
EasyAnalyzable {
    var ana :Prefix {
        return Prefix(target: self)
    }
}