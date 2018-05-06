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
        return UIViewControllerObserver(observee: self, owned: false)
    }
    public func
        tokenByAddingOwnedObserver() -> Reporting {
        return UIViewControllerObserver(observee: self, owned: true)
    }
}

class
    UIViewControllerObserver<ViewController> : HookingObserver<ViewController>
    where ViewController : UIViewController
{
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
            self.recorder?.recordEventOnPath(named: "ana-appeared")
        case String(describing: #selector(UIViewController.viewDidDisappear(_:))):
            self.recorder?.recordEventOnPath(named: "ana-disappeared")
        default:
            return super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    class override var
    decorator :AnyClass {
        return ANAUIViewController.self
    }
}
