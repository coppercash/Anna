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

@objc(ANAFocusPathConstitutionForwarding)
public protocol
    FocusPathConstitutionForwarding
{
    @objc(ana_parentConstitutorForChild:owning:)
    func
        forwardingConstitutor(
        for anothor :FocusPathConstituting,
        isOwning :UnsafeMutablePointer<Bool>
        ) -> FocusPathConstituting?
}

