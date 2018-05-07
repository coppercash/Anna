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
    override func
        observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
        ) {
        switch keyPath {
        case #keyPath(UIView.isVisible):
            guard let isVisible = change?[.newKey] as? Bool else { return }
            self.recordVisibility(isVisible)
        default:
            guard let event = change?.toEvent() else { return }
            switch event.name {
            case String(describing: #selector(UIView.didMoveToWindow)): fallthrough
            case String(describing: #selector(UIView.didMoveToSuperview)):
                guard let view = object as? UIView else { return }
                self.recordVisibility(view.isVisible)
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
    var
    isViewVisible :Bool = false
    func
        recordVisibility(
        _ isVisible :Bool
        ) {
        guard isVisible != self.isViewVisible else { return }
        self.isViewVisible = isVisible
        let
        event = isVisible ? "ana-appeared" : "ana-disappeared"
        self.recorder?.recordEventOnPath(
            named: event,
            with: nil
        )
    }
    class override var
    keyPaths :[String: NSKeyValueObservingOptions] {
        return super.keyPaths.merging([
            #keyPath(UIView.isVisible): [.new, .initial]
        ]) { $0.0 }
    }
    class override var
    decorator :AnyClass? {
        return ANAUIView.self
    }
}

extension
    UIView
{
    @objc(ana_isVisible)
    var isVisible :Bool {
        let
        view = self
        return (view.window != nil) &&
            (view.superview != nil) &&
            (view.isHidden == false)
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
