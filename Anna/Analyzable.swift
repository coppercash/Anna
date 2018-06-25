//
//  Analyzable.swift
//  Anna_iOS
//
//  Created by William on 2018/5/5.
//

import Foundation

@objc(ANAAnalyzable)
public protocol
    Analyzable : AnalyzerReadable, Hookable
{}

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
    @objc(recordEvent:withAttributes:)
    func
        record(
        _ event :String,
        with attributes :Manager.Attributes?
    )
    @objc(enableNaming:)
    func
        enable(naming :String)
    @objc(setSubAnalyzer:forKey:)
    func
        setSubAnalyzer(
        _ sub :Analyzing,
        for key :String
    )
    @objc(setSubAnalyzers:forKey:)
    func
        setSubAnalyzers(
        _ subs :[Analyzing],
        for key :String
    )
}

@objc(ANAAnalyzerReadable)
public protocol
    AnalyzerReadable
{
    @objc(ana_analyzer)
    var
    analyzer :Analyzing { get }
}

@objc(ANAAnalyzerWritable)
public protocol
    AnalyzerWritable : AnalyzerReadable
{
    @objc(ana_analyzer)
    var
    analyzer :Analyzing { get set }
}
