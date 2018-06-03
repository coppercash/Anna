//
//  UITableViewCell+Hookable.swift
//  Anna_iOS
//
//  Created by William on 2018/5/1.
//

import UIKit

extension
    UITableViewCell
{
    public override func
        tokenByAddingObserver() -> Reporting {
        return UITableViewCellObserver(observee: self, owned: false)
    }
    public override func
        tokenByAddingOwnedObserver() -> Reporting {
        return UITableViewCellObserver(observee: self, owned: true)
    }
    func
        tableViewDelegateByLookingUp() -> (UITableViewDelegate & NSObject)? {
        var
        current :UIView? = self.superview
        while let view = current {
            if let
                table = view as? UITableView,
                let
                delegate = table.delegate as? (UITableViewDelegate & NSObject)
            { return delegate }
            current = view.superview
        }
        return nil
    }
}

class
    UITableViewCellObserver<Observee> : UIViewObserver<Observee>
    where Observee : UITableViewCell
{
    class override var
    decorators :[AnyClass] {
        return super.decorators + [ANAUITableViewCell.self]
    }
    override func
        observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
        ) {
        switch change?.toEvent()?.name {
        case String(describing: #selector(UITableViewDelegate.tableView(_:willDisplay:forRowAt:))):
            self.visibilityRecorder.record(true)
        case String(describing: #selector(UITableViewDelegate.tableView(_:didEndDisplaying:forRowAt:))):
            self.visibilityRecorder.record(false)
        case String(describing: #selector(UITableViewDelegate.tableView(_:didSelectRowAt:))):
            self.recorder?.recordEventOnPath(
                named: "did-select",
                with: nil
            )
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

extension
    UITableViewCell
{
    @objc(ana_prepareAnalyzerForReuse)
    public func
        prepareAnalyzerForReuse() {
        guard let
            analyzer = (self as? AnalyzerReadable)?.analyzer as? Analyzer
            else { return }
        try! analyzer.deactivate()
    }
    open override func
        parentConstitutor(
        isOwning: UnsafeMutablePointer<Bool>
        ) -> FocusPathConstituting? {
        return nil
    }
}
