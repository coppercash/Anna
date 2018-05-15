//
//  UIResponder+PathConstituting.swift
//  Anna_iOS
//
//  Created by William on 2018/4/18.
//

import UIKit

extension
    UIResponder : FocusPathConstituting, FocusPathConstitutionForwarding
{
    open func
        parentConstitutor(
        isOwning: UnsafeMutablePointer<Bool>
        ) -> FocusPathConstituting? {
        return self.next?.forwardingConstitutor(
            for: self,
            isOwning: isOwning
        )
    }
    open func
        forwardingConstitutor(
        for another: FocusPathConstituting,
        isOwning: UnsafeMutablePointer<Bool>
        ) -> FocusPathConstituting? {
        return self
    }
}

extension
    UIViewController
{
    open override func
        parentConstitutor(
        isOwning: UnsafeMutablePointer<Bool>
        ) -> FocusPathConstituting? {
        if let
            parent = self.presentingViewController ?? self.tabBarController ?? self.navigationController 
        {
            return parent.forwardingConstitutor(
                for: self,
                isOwning: isOwning
            )
        }
        else {
            return super.parentConstitutor(
                isOwning: isOwning
            )
        }
    }
}

extension
    UINavigationController
{
    open override func
        forwardingConstitutor(
        for another: FocusPathConstituting,
        isOwning: UnsafeMutablePointer<Bool>
        ) -> FocusPathConstituting? {
        let
        siblings = self.viewControllers
        var
        index :Int? = nil
        for i in stride(from: 0, to: siblings.count, by: 1).reversed() {
            if siblings[i] === another {
                index = i
                break
            }
        }
        guard let
            i = index
            else
        {
            guard let
                last = siblings.last
                else
            {
                return super.forwardingConstitutor(
                    for: another,
                    isOwning: isOwning
                )
            }
            return last.forwardingConstitutor(
                for: another,
                isOwning: isOwning
            )
        }
        guard i > 0 else {
            return super.forwardingConstitutor(
                for: another,
                isOwning: isOwning
            )
        }
        return siblings[i - 1].forwardingConstitutor(
            for: another,
            isOwning: isOwning
        )
    }
}

extension
    UIView
{
    open override func
        parentConstitutor(
        isOwning: UnsafeMutablePointer<Bool>
        ) -> FocusPathConstituting? {
        isOwning.assign(
            repeating: true,
            count: 1
        )
        var
        skipping = false
        return super.parentConstitutor(isOwning: &skipping)
    }
}

extension
UITableViewCell
{
    open override func
        parentConstitutor(
        isOwning: UnsafeMutablePointer<Bool>
        ) -> FocusPathConstituting? {
        return nil
    }
}
