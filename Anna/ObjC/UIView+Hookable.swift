//
//  UIView+Hookable.swift
//  Anna_iOS
//
//  Created by William on 2018/5/2.
//

import Foundation

extension
    UIView : Hookable
{
    public func
        tokenByAddingObserver() -> Reporting {
        return UIViewObserver(observee: self)
    }
}

class
    UIViewObserver : BaseObserver<UIView>
{
    init
        (observee: UIView) {
        super.init(observee: observee)
    }
}
