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
    public func
        parentConstitutor(
        isOwning: UnsafeMutablePointer<Bool>
        ) -> FocusPathConstituting? {
        return self.next?.forwardingConstitutor(
            for: self,
            isOwning: isOwning
        )
    }
    public func
        forwardingConstitutor(
        for anothor: FocusPathConstituting,
        isOwning: UnsafeMutablePointer<Bool>
        ) -> FocusPathConstituting? {
        return self
    }
}

extension
    UINavigationController
{
    public override func
        forwardingConstitutor(
        for anothor: FocusPathConstituting,
        isOwning: UnsafeMutablePointer<Bool>
        ) -> FocusPathConstituting? {
        let
        navigation = self.navigationController,
        siblings = self.viewControllers
        var
        index :Int? = nil
        for i in stride(from: 0, to: siblings.count, by: 1).reversed() {
            if siblings[i] === anothor {
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
