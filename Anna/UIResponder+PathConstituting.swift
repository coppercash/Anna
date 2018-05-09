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
        parentConsititutor(
        for child :PathConstituting,
        requiredFrom descendant :PathConstituting
        ) -> PathConstituting? {
        return self.next
    }
}

extension
    UIViewController
{
    open override func
        parentConsititutor(
        for child :PathConstituting,
        requiredFrom descendant :PathConstituting
        ) -> PathConstituting? {
        let
        controller = self;
        if let
            navigation = self.navigationController {
            let
            siblings = navigation.viewControllers
            var
            index :Int? = nil
            for i in stride(from: 0, to: siblings.count, by: 1).reversed() {
                if siblings[i] === controller {
                    index = i
                    break
                }
            }
            if let
                index = index
            {
                return index > 0 ? siblings[index - 1] : navigation
            }
            else {
                return siblings.last ?? navigation
            }
        }
        else {
            return super.parentConsititutor(
                for: child,
                requiredFrom: descendant
            )
        }
    }
}

extension
UITableViewCell
{
    open override func
        parentConsititutor(
        for child :PathConstituting,
        requiredFrom descendant :PathConstituting
        ) -> PathConstituting? {
        return nil
    }
}
