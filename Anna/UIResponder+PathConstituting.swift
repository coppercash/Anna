//
//  UIResponder+PathConstituting.swift
//  Anna_iOS
//
//  Created by William on 2018/4/18.
//

import UIKit

extension
    UIResponder : FocusPathConstituting, FocusPathConstitutionRedirecting
{
    open func
        parentConstitutor(
        isOwning: UnsafeMutablePointer<Bool>
        ) -> FocusPathConstituting? {
        return self.next?.redirectedConstitutor(
            for: self,
            isOwning: isOwning
        )
    }
    open func
        redirectedConstitutor(
        for another: FocusPathConstituting,
        isOwning: UnsafeMutablePointer<Bool>
        ) -> FocusPathConstituting? {
        if
            (another as? UIResponder)?.next !== self,
            let
            analyzer = (self as? AnalyzerReadable)?.analyzer as? Analyzer,
            let
            focused = analyzer.latestFocusedObject,
            focused !== self
        {
            return focused.redirectedConstitutor(
                for: another,
                isOwning: isOwning
            )
        }
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
            return parent.redirectedConstitutor(
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
        redirectedConstitutor(
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
                return super.redirectedConstitutor(
                    for: another,
                    isOwning: isOwning
                )
            }
            return last.redirectedConstitutor(
                for: another,
                isOwning: isOwning
            )
        }
        guard i > 0 else {
            return super.redirectedConstitutor(
                for: another,
                isOwning: isOwning
            )
        }
        return siblings[i - 1].redirectedConstitutor(
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
