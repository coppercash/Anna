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
        writable = self as! AnalyzerWritable
        guard
            writable.analyzer == nil
            else { return }
        let
        delegate = (self as! Analyzer.Delegate & Hookable),
        analyzer = Analyzer(
            delegate: delegate
        )
        writable.analyzer = analyzer
        analyzer.enable(with: name)
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
    @objc(detach)
    func
        detach()
    @objc(markFocused)
    func
        markFocused()
    @objc(updateValue:forKeyPath:)
    func
        update(
        _ value :Any?,
        for keyPath :String
    )
    @objc(recordEvent:)
    func
        record(
        _ event :String
    )
    @objc(enableWithName:)
    func
        enable(with name :String)
    @objc(addSubAnalyzer:named:)
    func
        addSubAnalyzer(
        _ sub :Analyzing,
        named name:String
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
