//
//  PathTestCaseBuilder.swift
//  Anna_iOS_Tests
//
//  Created by William on 2018/4/14.
//

import Foundation
import UIKit
import XCTest

@objc(ANAPathTestCaseBuilder) class
PathTestCaseBuilder : NSObject
{
    var
    defaultScript :String? = nil
    var
    rootViewController :UIViewController? = nil
    
    func
        launch() {
        
    }
    
    func
        expectResult() {
        
    }
    
    var
    expectations = [XCTestExpectation]()
    var
    results = [AnyObject]()
}

@objc(ANAPathTestingViewController) class
PathTestingViewController : UIViewController
{
    let
    nodeName :String
    @objc(initWithNodeName:)
    init(with nodeName :String) {
        self.nodeName = nodeName
        super.init(nibName: nil, bundle: nil)
    }
    
    required
    init?(coder aDecoder: NSCoder) {
        self.nodeName = String(describing: aDecoder)
        super.init(coder: aDecoder)
    }
}

@objc(ANAPathTestingButton) class
    PathTestingButton : UIButton
{
    let
    nodeName :String
    @objc(initWithNodeName:)
    init(with nodeName :String) {
        self.nodeName = nodeName
        super.init(frame: CGRect.zero)
    }
    
    required
    init?(coder aDecoder: NSCoder) {
        self.nodeName = String(describing: aDecoder)
        super.init(coder: aDecoder)
    }
}
