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
        return UIControlObserver(observee: self, owned: false)
    }
    public override func
        tokenByAddingOwnedObserver() -> Reporting {
        return UIControlObserver(observee: self, owned: true)
    }
}

class
    UIControlObserver<Observee> : UIViewObserver<Observee>
    where Observee : UIControl
{
    required
    init(
        observee: Observee,
        owned: Bool
        ) {
        super.init(
            observee: observee,
            owned: owned
        )
        if owned == false {
            self.visibilityRecorder = VisibilityRecorder(
                activeEvents: []
            )
        }
    }
    override func
        observe(_ observee: Observee) {
        super.observe(observee)
        observee.addTarget(
            self,
            action: #selector(handleTouchUpInside(on:with:)),
            for: .touchUpInside
        )
    }
    override func
        deobserve(_ observee: Observee) {
        super.deobserve(observee)
        observee.removeTarget(
            self,
            action: #selector(handleTouchUpInside(on:with:)),
            for: .touchUpInside
        )
    }
    @objc func
        handleTouchUpInside(
        on control :UIControl,
        with event :UIEvent
        ) {
        control.forwardRecordingEvent(named: "touch-up-inside")
    }
}
