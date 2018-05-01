//
//  UIViewController+Hookable.swift
//  Anna_iOS
//
//  Created by William on 2018/5/1.
//

import UIKit

extension
    UIViewController : Hookable
{
    public func
        tokenByAddingObserver() -> Reporting {
        return UIViewControllerObserver(observee: self)
    }
}

class
    UIViewControllerObserver : BaseObserver<UIViewController>
{
    init
        (observee: UIViewController) {
        super.init(observee: observee)
    }
}
