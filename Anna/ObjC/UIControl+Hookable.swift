//
//  UIControl+Hookable.swift
//  Anna_iOS
//
//  Created by William on 2018/5/2.
//

import UIKit

extension
    UIControl
{
    public override func
        tokenByAddingObserver() -> Reporting {
        return UIControlObserver(observee: self)
    }
}

class
    UIControlObserver : AbstractUIViewObserver<UIControl>
{
    override init
        (observee: UIControl) {
        super.init(observee: observee)
        observee.addTarget(
            self,
            action: #selector(handleTouchUpInside(on:with:)),
            for: .touchUpInside
        )
    }
    deinit {
        self.observee?.removeTarget(
            self,
            action: #selector(handleTouchUpInside(on:with:)),
            for: .touchUpInside
        )
    }
    
    func
        handleTouchUpInside(
        on control :UIControl,
        with event :UIEvent
        ) {
        control.forwardRecordingEvent(named: "ui-control-event")
    }
}
