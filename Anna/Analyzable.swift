//
//  Analyzable.swift
//  Anna_iOS
//
//  Created by William on 2018/5/5.
//

import Foundation

@objc(ANAAnalyzable)
public protocol
    Analyzable : AnalyzerHolding
{
}

@objc(ANAAnalyzing)
public protocol
    Analyzing
{
    // Keep this empty
    // no promised action after being registered
    //
}

@objc(ANAAnalyzerOwning)
public protocol
    AnalyzerOwning
{
    @objc(ana_analyzer)
    var
    analyzer :Analyzing? { get }
}

@objc(ANAAnalyzerHolding)
public protocol
    AnalyzerHolding : AnalyzerOwning
{
    @objc(ana_analyzer)
    var
    analyzer :Analyzing? { get set }
}

