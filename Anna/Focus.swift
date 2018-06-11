//
//  Focus.swift
//  Anna_iOS
//
//  Created by William on 2018/5/19.
//

import Foundation

protocol
    FocusHandling
{
    typealias
    Object = FocusPathConstituting & FocusPathConstitutionRedirecting
    func
        handleFocused(_ object :Object)
}
