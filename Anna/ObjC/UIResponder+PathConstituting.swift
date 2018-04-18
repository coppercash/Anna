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
    
    open func
        pathNodeName() -> String {
        return String(describing: type(of: self))
    }
}
