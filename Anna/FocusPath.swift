//
//  FocusPath.swift
//  Anna_iOS
//
//  Created by William on 2018/5/14.
//

import Foundation

@objc(ANAFocusPathConstituting)
public protocol
    FocusPathConstituting
{
    @objc(ana_parentConstitutorOwning:)
    func
        parentConstitutor(
        isOwning :UnsafeMutablePointer<Bool>
        ) -> FocusPathConstituting?
}

@objc(ANAFocusPathConstitutionRedirecting)
public protocol
    FocusPathConstitutionRedirecting
{
    @objc(ana_redirectedConstitutorForAnother:owning:)
    func
        redirectedConstitutor(
        for another :FocusPathConstituting,
        isOwning :UnsafeMutablePointer<Bool>
        ) -> FocusPathConstituting?
}

