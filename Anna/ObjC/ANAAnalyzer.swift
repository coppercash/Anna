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

@objc(ANAAnalyzer)
public class
    Analyzer : NSObject
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
    UIControlAnalyzer : Analyzer
{
    @objc(hookControl:)
    public func
        hook(_ control :UIControl)
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
