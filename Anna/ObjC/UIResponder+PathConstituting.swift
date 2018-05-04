//
//  UIResponder+PathConstituting.swift
//  Anna_iOS
//
//  Created by William on 2018/4/18.
//

import UIKit

extension
    UIResponder : PathConstituting
{
    open func
        parentConsititutor() -> PathConstituting? {
        return self.next
    }
}

extension
    UIViewController
{
    open override func
        parentConsititutor() -> PathConstituting? {
        if let
            navigation = self.navigationController {
            var
            current :UIViewController? = nil;
            for v in navigation.viewControllers.reversed() {
                if let _ = current {
                    return v
                }
                else if (v === self) {
                    current = v;
                }
            }
            return navigation
        }
        else {
            return super.parentConsititutor()
        }
    }
}
