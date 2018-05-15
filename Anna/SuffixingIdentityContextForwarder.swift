//
//  SuffixingIdentityContextForwarder.swift
//  Anna_iOS
//
//  Created by William on 2018/5/15.
//

import Foundation

class
    SuffixingIdentityContextForwarder : IdentityContextResolving
{
    weak var
    target :IdentityContextResolving?
    lazy var
    suffix :NodeID = {
        return NodeID(owner: self)
    }()
    init(
        target :IdentityContextResolving
        ) {
        self.target = target
    }
    var
    resolvedContext: IdentityContext? {
        return self.target?.resolvedContext
    }
    func
        resolveContext(
        then callback: @escaping IdentityContextResolving.Callback
        ) throws {
        let
        suffix = self.suffix
        try self.target?.resolveContext { pContext in
            try callback(IdentityContext(
                manager: pContext.manager,
                parentID: pContext.parentID,
                identifier: pContext.identifier,
                suffix: suffix
            ))
        }
    }
    func
        notifyAfterContextReset(
        _ notify: @escaping IdentityContextResolving.Notify
        ) {
        self.target?.notifyAfterContextReset(notify)
    }
}
