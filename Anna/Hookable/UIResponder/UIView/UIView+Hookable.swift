//
//  UIView+Hookable.swift
//  Anna_iOS
//
//  Created by William on 2018/5/2.
//

import Foundation

extension
    UIView
{
    public override func
        tokenByAddingObserver() -> Reporting {
        return UIViewObserver(observee: self, owned: false)
    }
    public override func
        tokenByAddingOwnedObserver() -> Reporting {
        return UIViewObserver(observee: self, owned: true)
    }
}

class
    UIViewObserver<Observee> : UIResponderObserver<Observee>
    where Observee : UIView
{
    var
    visibilityRecorder :VisibilityRecorder
    override var
    recorder: Reporting.Recorder? {
        willSet {
            self.visibilityRecorder.recorder = newValue
        }
    }
    required
    init(
        observee: Observee,
        owned: Bool
        ) {
        self.visibilityRecorder = VisibilityRecorder(
            activeEvents: [.appeared, .disappeared]
        )
        super.init(
            observee: observee,
            owned: owned
        )
    }
    override func
        observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
        ) {
        switch keyPath! {
        case #keyPath(UIView.isVisible):
            guard let isVisible = change?[.newKey] as? Bool else { return }
            self.visibilityRecorder.record(isVisible)
        default:
            guard let event = change?.toEvent() else { return }
            switch event.name {
            case String(describing: #selector(UIView.didMoveToWindow)): fallthrough
            case String(describing: #selector(UIView.didMoveToSuperview)):
                guard let view = object as? UIView else { return }
                self.visibilityRecorder.record(view.isVisible)
            default:
                return super.observeValue(
                    forKeyPath: keyPath,
                    of: object,
                    change: change,
                    context: context
                )
            }
        }
    }
    class override var
    keyPaths :[String: NSKeyValueObservingOptions] {
        return super.keyPaths.merging([
            #keyPath(UIView.isVisible): [.new, .initial]
        ]) { (key, _) in return key }
    }
    class override var
    decorators :[AnyClass] {
        return super.decorators + [ANAUIView.self]
    }
}

extension
    UIView
{
    @objc(ana_isVisible)
    var isVisible :Bool {
        let
        view = self
        return (view.isHidden == false) &&
            (view.superview != nil) &&
            (view.window != nil)
    }
    @objc(keyPathsForValuesAffectingAna_isVisible)
    class var
    keyPathsForValuesAffectingIsVisible :Set<String> {
        return Set(
            arrayLiteral:
            #keyPath(isHidden)
        )
    }
}
