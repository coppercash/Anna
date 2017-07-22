//
//  Sender.swift
//  Anna
//
//  Created by William on 10/06/2017.
//
//

import Foundation

public protocol
EasyAnalyzable : class, EasyRegistrant {
    typealias
        Manager = EasyManager
    var
    analyticsManager :Manager { get }
    typealias
        Prefix = EasyPrefix
    var
    ana :Prefix { get }
}

public extension
EasyAnalyzable {
    var
    ana :Prefix {
        return EasyPrefix(target: self)
    }
    var
    analyticsManager :Manager {
       return EasyManager.shared
    }
}
