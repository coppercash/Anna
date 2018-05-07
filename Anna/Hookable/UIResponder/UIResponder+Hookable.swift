//
//  UIResponder+Hookable.swift
//  Anna_iOS
//
//  Created by William on 2018/5/7.
//

import UIKit

extension
UIResponder : Hookable {
    public func
        tokenByAddingObserver() -> Reporting {
        return UIResponderObserver(observee: self, owned: false)
    }
    public func
        tokenByAddingOwnedObserver() -> Reporting {
        return UIResponderObserver(observee: self, owned: true)
    }
}

class
    UIResponderObserver<Observee> : HookingObserver<Observee>
    where Observee : UIResponder
{ }
