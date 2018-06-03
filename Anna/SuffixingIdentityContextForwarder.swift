//
//  PrefixingIdentityContextForwarder.swift
//  Anna_iOS
//
//  Created by William on 2018/5/15.
//

import Foundation

class
    PrefixingIdentityContextForwarder : IdentityContextResolving, FocusHandling
{
    typealias
    Target = IdentityContextResolving & FocusHandling
    weak var
    target :Target?
    let
    prefix :NodeID
    init(
        target :Target,
        prefix :NodeID
        ) {
        self.target = target
        self.prefix = prefix
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
        prefix = self.prefix
        try self.target?.resolveContext { pContext in
            /*
            try callback(IdentityContext(
                manager: pContext.manager,
                parentID: pContext.parentID,
                identifier: pContext.identifier,
                prefix: prefix
            ))
 */
        }
    }
    func
        notifyAfterContextReset(
        _ notify: @escaping IdentityContextResolving.Notify
        ) {
        self.target?.notifyAfterContextReset(notify)
    }
    func
        handleFocused(_ object: FocusHandling.Object) {
        self.target?.handleFocused(object)
    }
}
