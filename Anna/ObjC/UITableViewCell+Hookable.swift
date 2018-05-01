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
        return UITableViewCellObserver(observee: self)
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
    UITableViewCellObserver : BaseObserver<UITableViewCell>
{
    init
        (observee: UITableViewCell) {
        super.init(observee: observee)
    }
}
