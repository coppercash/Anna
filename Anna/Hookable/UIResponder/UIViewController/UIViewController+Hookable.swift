//
//  UIViewController+Hookable.swift
//  Anna_iOS
//
//  Created by William on 2018/5/1.
//

import UIKit

extension
    UIViewController 
{
    public override func
        tokenByAddingObserver() -> Reporting {
        return UIViewControllerObserver(observee: self)
    }
}

class
    UIViewControllerObserver<Observee> : UIResponderObserver<Observee>
    where Observee : UIViewController
{
    let
    visibilityRecorder :VisibilityRecorder
    override var
    recorder: Reporting.Recorder? {
        didSet {
            self.visibilityRecorder.recorder = self.recorder
        }
    }
    required
    init(
        observee: Observee
        ) {
        self.visibilityRecorder = VisibilityRecorder(
            activeEvents: [.appeared, .disappeared]
        )
        super.init(
            observee: observee
        )
    }
    override func
        observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
        ) {
        guard let event = change?.toEvent() else { return }
        switch event.name {
        case String(describing: #selector(UIViewController.viewDidAppear(_:))):
            self.visibilityRecorder.record(true)
        case String(describing: #selector(UIViewController.viewDidDisappear(_:))):
            self.visibilityRecorder.record(false)
        default:
            return super.observeValue(
                forKeyPath: keyPath,
                of: object,
                change: change,
                context: context
            )
        }
    }
    class override var
    decorators :[AnyClass] {
        return super.decorators + [ANAUIViewController.self]
    }
}
