//
//  ANAAnalyzer.swift
//  Anna_iOS
//
//  Created by William on 2018/4/15.
//

import Foundation

//@objc(ANAAnalyzerOwner)
//public protocol
//    AnalyzerOwner
//{
//    var
//    ana_analyzer :ANAAnalyzer { get set }
//}
//
//extension
//    NSObject : AnalyzerOwner
//{
//    public var
//    ana_analyzer: ANAAnalyzer {
//        get {
//            
//        }
//    }
//}

@objc
public protocol
ANAPathConsituting
{
    
}

public class
    ANAAnalyzer : NSObject
{
    public typealias
        Delegate = ANAPathConsituting
    var
    delegate :Delegate
    
    @objc(initWithDelegate:)
    public init
        (with delegate: Delegate)
    {
        self.delegate = delegate
    }
    
    public func
        observe()
    {
        
    }
}

@objc(ANAUIControlAnalyzer)
public class
    UIControlAnalyzer : ANAAnalyzer
{
    @objc(hookControl:)
    public func
        hook(control :UIControl)
    {
        control.addTarget(
            self,
            action: #selector(handle(control:event:)),
            for: .allEvents)
    }
    
    func
        handle(control :UIControl, event :UIEvent)
    {
        
    }
}
