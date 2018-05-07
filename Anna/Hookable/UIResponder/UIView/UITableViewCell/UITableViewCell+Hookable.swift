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
    decorator :AnyClass? { return nil }
}