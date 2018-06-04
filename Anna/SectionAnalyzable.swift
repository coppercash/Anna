//
//  SectionAnalyzable.swift
//  Anna_iOS
//
//  Created by William on 2018/6/4.
//

import Foundation

protocol
    SectionAnalyzable
{
    func
        analyticName(
        for section :Int
        ) -> String?
    func
        didCreate(
        _ analyzer :Analyzing,
        for section :Int
    )
}

func
_configure(
    cell :AnalyzerReadable,
    in view :AnalyzerReadable & SectionAnalyzable,
    at indexPath :IndexPath
    ) throws {
    guard
        let
        table = view.analyzer as? Analyzer,
        let
        row = cell.analyzer as? Analyzer
        else { return }
    if let
        secName = view.analyticName(for: indexPath.section)
    {
        var
        section = table.subordinary(for: indexPath.section) as? Analyzer
        if section == nil {
            let
            analyzer = Analyzer(
                delegate: table
            )
            try analyzer.activate(
                under: table,
                key: secName,
                index: indexPath.section
            )
            view.didCreate(
                analyzer,
                for: indexPath.section
            )
            
            let
            vr = VisibilityRecorder(
                activeEvents: [.appeared, .disappeared]
            )
            vr.recorder = analyzer
            analyzer.tokens.append(vr)
            vr.record(true)
            
            table.setSubordinary(analyzer, for: indexPath.section)
            section = analyzer
        }
        guard let
            key = row.parentlessName
            else { return }
        try row.activate(under: section!) {
            let
            manager = $0.manager,
            parentID = $0.nodeID
            return IdentityContext(
                manager: manager,
                nodeID: parentID.appended(["\(indexPath.row)"]),
                parentID: parentID,
                name: key,
                index: indexPath.row
            )
        }
    }
    else {
        guard let
            key = row.parentlessName
            else { return }
        var
        section = table.subordinary(for: indexPath.section) as? ForwardingAnalyzer
        if section == nil {
            let
            analyzer = ForwardingAnalyzer(target: table)

            table.setSubordinary(analyzer, for: indexPath.section)
            section = analyzer
        }
        let
        sectionID :NodeID = section!.owningID
        try row.activate(under: section) {
            let
            manager = $0.manager,
            parentID = $0.nodeID
            return IdentityContext(
                manager: manager,
                nodeID: sectionID.appended(["\(indexPath.row)"]),
                parentID: parentID,
                name: key,
                index: indexPath.row
            )
        }
    }
}
