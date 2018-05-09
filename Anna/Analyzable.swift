//
//  Analyzable.swift
//  Anna_iOS
//
//  Created by William on 2018/5/5.
//

import Foundation

@objc(ANAAnalyzable)
public protocol
    Analyzable : AnalyzerWritable & Hookable
{
    @objc(ana_becomeAnalysisObjectNamed:)
    func
        becomeAnalysisObject(named name :String)
}

public extension
    NSObject
{
    @objc(ana_becomeAnalysisObjectNamed:)
    public func
        becomeAnalysisObject(
        named name :String
        ) {
        let
        writable = self as! AnalyzerWritable,
        delegate = (self as! Analyzer.Delegate & Hookable),
        analyzer = Analyzer(
            with: name,
            delegate: delegate
        )
        analyzer.hook(owner: delegate)
        writable.analyzer = analyzer
    }
}

@objc(ANAAnalyzing)
public protocol
    Analyzing
{
    @objc(hookObject:)
    func
        hook(_ hookee :Hookable)
    @objc(observeObject:forKeyPath:)
    func
        observe(
        _ observee :NSObject,
        for keyPath :String
    )
    @objc(observeOwner:forKeyPath:)
    func
        observe(
        owner :NSObject,
        for keyPath :String
    )
    @objc(updateValue:forKeyPath:)
    func
        update(
        _ value :Any,
        for keyPath :String
    )
}

@objc(ANAAnalyzerReadable)
public protocol
    AnalyzerReadable
{
    @objc(ana_analyzer)
    var
    analyzer :Analyzing? { get }
}

@objc(ANAAnalyzerWritable)
public protocol
    AnalyzerWritable : AnalyzerReadable
{
    @objc(ana_analyzer)
    var
    analyzer :Analyzing? { get set }
}

@objc(ANAPathConstituting)
public protocol
    PathConstituting
{
    @objc(ana_parentConsititutorForChild:requiredFromDescendant:)
    func
        parentConsititutor(
        for child :PathConstituting,
        requiredFrom descendant :PathConstituting
        ) -> PathConstituting?
}

