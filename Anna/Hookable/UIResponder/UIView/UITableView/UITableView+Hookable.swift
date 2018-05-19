//
//  UITableView+Hookable.swift
//  Anna_iOS
//
//  Created by William on 2018/5/1.
//

import UIKit

extension
    UITableView
{
    public override func
        tokenByAddingObserver() -> Reporting {
        return UITableViewObserver(observee: self, owned: false)
    }
    public override func
        tokenByAddingOwnedObserver() -> Reporting {
        return UITableViewObserver(observee: self, owned: true)
    }
}

// Why reseting flags
// https://github.com/BigZaphod/Chameleon/blob/master/UIKit/Classes/UITableView.m
//
class
    UITableViewObserver<Observee> : UIViewObserver<Observee>
    where Observee : UITableView
{
    var
    dataSource :UITableViewDataSourceProxy? = nil,
    delegate :UITableViewDelegateProxy? = nil
    override func
        observe(_ observee: Observee) {
        super.observe(observee)
        let
        dataSource = observee.dataSource as! (UITableViewDataSource & NSObject)
        self.dataSource = UITableViewDataSourceProxy(dataSource)
        observee.dataSource = self.dataSource
        
        let
        delegate = observee.delegate as! (UITableViewDelegate & NSObject)
        self.delegate = UITableViewDelegateProxy(delegate)
        observee.delegate = self.delegate
    }
    override func
        deobserve(_ observee: Observee) {
        super.deobserve(observee)
        if let delegate = self.delegate?.target {
            // Reset `UITableView._delegateHas`
            //
            observee.delegate = delegate
        }
        if let dataSource = self.dataSource?.target {
            // Reset `UITableView._dataSourceHas`
            //
            observee.dataSource = dataSource
        }
    }
}

class
    Proxy<Target : NSObjectProtocol> : NSObject
{
    weak var
    target :Target?
    init(_ target :Target) {
        self.target = target
    }
    
    override func
        conforms(to aProtocol: Protocol) -> Bool {
        return self.target?.conforms(to: aProtocol) ?? false
    }
    
    override func
        forwardingTarget(for aSelector: Selector!) -> Any? {
        return self.target
    }
    
    override func
        responds(to aSelector: Selector!) -> Bool {
        return type(of: self).instancesRespond(to: aSelector) ||
            (self.target?.responds(to: aSelector) ?? false)
    }
}

class
    UITableViewDelegateProxy : Proxy<UITableViewDelegate>, UITableViewDelegate
{
    func
        tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
        ) {
        cell.forwardRecordingEvent(named: "will-display")
        self.target?.tableView?(
            tableView,
            willDisplay: cell,
            forRowAt: indexPath
        )
    }
    func
        tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
        ) {
        if let
            cell = tableView.cellForRow(at: indexPath),
            let
            analyzer = (cell as? AnalyzerReadable)?.analyzer as? FocusHandling
        {
            analyzer.handleFocused(cell)
        }
        self.target?.tableView?(
            tableView,
            didSelectRowAt: indexPath
        )
    }
}

extension
UITableView
{
    typealias
    SectionAnalyzer = Analyzer & IdentityContextResolving
    func
        resolvedSubAnalyzer(
        for section :Int
        ) -> SectionAnalyzer? {
        guard let
            owner = self as? UITableView & AnalyzerReadable,
            let
            table = owner.analyzer as? Analyzer
            else { return nil }
        if let
            resolved = table.childAnalyzer[section] as? SectionAnalyzer
        { return resolved }
        guard let
            delegate = self.delegate as? SectionAnalyzableTableViewDelegate,
            let
            name = delegate.tableView(
                owner,
                analyticNameFor: section
            )
            else { return nil }
        let
        analyzer = Analyzer(
            with: name,
            delegate: table
        )
        delegate.tableView?(
            owner,
            didCreate: analyzer,
            for: section
        )
        table.childAnalyzer[section] = analyzer
        return analyzer
    }
}

class
    UITableViewDataSourceProxy : Proxy<UITableViewDataSource>, UITableViewDataSource
{
    func
        tableView(
        _ tableView:
        UITableView,
        numberOfRowsInSection section: Int
        ) -> Int {
        return self.target?.tableView(tableView, numberOfRowsInSection: section) ?? 0
    }
    
    func
        tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
        ) -> UITableViewCell {
        let
        cell = self.target!.tableView(tableView, cellForRowAt: indexPath)
        guard
            let
            analyzable = cell as? AnalyzerReadable,
            let
            row = analyzable.analyzer as? Analyzer
        else { return cell }
        
        let
        section = tableView.resolvedSubAnalyzer(for: indexPath.section),
        parent = section ?? ((tableView as! AnalyzerReadable).analyzer as! Analyzer),
        prefix = NodeID(owner: parent) + (
            section == nil ?
                [UInt(indexPath.section), UInt(indexPath.row)] :
                [UInt(indexPath.row)]
        )

        let
        forwarder :PrefixingIdentityContextForwarder
        if let
            resolved = parent.childAnalyzer[indexPath] as? PrefixingIdentityContextForwarder
        {
            forwarder = resolved
        }
        else {
            forwarder = PrefixingIdentityContextForwarder(
                target: parent,
                prefix: prefix
            )
            parent.childAnalyzer[indexPath] = forwarder
        }
        row.resolvedParenthood = Analyzer.FocusParenthood(
            parent: forwarder,
            child: row,
            isOwning: true
        )
        try! row.flushDeferredResolutions()

        return cell
    }
}

@objc(ANASectionAnalyzableTableViewDelegate)
public protocol
    SectionAnalyzableTableViewDelegate
{
    @objc(tableView:didCreateAnalyzer:forSection:)
    optional func
        tableView(
        _ tableView: UITableView & AnalyzerReadable,
        didCreate analyzer :Analyzing,
        for section :Int
        ) -> Void
    @objc(tableView:analyticNameForSection:)
    func
        tableView(
        _ tableView: UITableView & AnalyzerReadable,
        analyticNameFor section :Int
        ) -> String?
}
