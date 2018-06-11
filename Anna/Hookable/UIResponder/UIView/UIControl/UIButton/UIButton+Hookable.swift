//
//  UIButton+Hookable.swift
//  Anna_iOS
//
//  Created by William on 2018/5/19.
//

import UIKit

extension
    UIButton
{
    public override func
        tokenByAddingObserver() -> Reporting {
        return UIButtonObserver(observee: self, owned: false)
    }
    public override func
        tokenByAddingOwnedObserver() -> Reporting {
        return UIButtonObserver(observee: self, owned: true)
    }
}

class
    UIButtonObserver<Observee> : UIControlObserver<Observee>
    where Observee : UIButton
{
    @objc override func
        handleTouchUpInside(
        on control :UIControl,
        with event :UIEvent
        ) {
        super.handleTouchUpInside(
            on: control,
            with: event
        )
        (self.recorder as? FocusHandling)?.handleFocused(control)
    }
}
