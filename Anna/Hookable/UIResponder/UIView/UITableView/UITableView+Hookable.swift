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
    let
    target :Target
    init(_ target :Target) {
        self.target = target
    }
    
    override func
        conforms(to aProtocol: Protocol) -> Bool {
        return self.target.conforms(to: aProtocol)
    }
    
    override func
        forwardingTarget(for aSelector: Selector!) -> Any? {
        return self.target
    }
    
    override func
        responds(to aSelector: Selector!) -> Bool {
        return type(of: self).instancesRespond(to: aSelector) || self.target.responds(to: aSelector)
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
        self.target.tableView?(tableView, willDisplay: cell, forRowAt: indexPath)
        cell.forwardRecordingEvent(named: "ui-table-will-display-row")
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
        return self.target.tableView(tableView, numberOfRowsInSection: section)
    }
    
    func
        tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
        ) -> UITableViewCell {
        let
        cell = self.target.tableView(tableView, cellForRowAt: indexPath)
        
        guard let
            owner = tableView as? AnalyzerReadable,
            let
            analyzable = tableView.delegate as? AnalyzableTableViewDelegate
            else { return cell }
        
        // TODO: Remove the force casting to ANAAnalyzer
        var
        analyzer = owner.analyzer as! Analyzer
        
        if let
            section = analyzable.tableView?(tableView, analyzerNameFor: indexPath.section) {
           analyzer = analyzer.resolvedSubAnalyzer(named: section) as! Analyzer
        }
        
        if let
            row = analyzable.tableView(tableView, analyzerNameForRowAt: indexPath) {
            analyzer = analyzer.resolvedSubAnalyzer(named: row) as! Analyzer
            if let
                holder = cell as? AnalyzerWritable {
                if let
                    old = holder.analyzer {
                    analyzer.takePlace(of: old as! Analyzer)
                }
                else {
                    analyzer.hook(owner: cell)
                }
                holder.analyzer = analyzer
            }
        }
        
        return cell
    }
}

@objc(ANAAnalyzableTableViewDelegate)
public protocol
    AnalyzableTableViewDelegate
{
    @objc(tableView:analyzerNameForRowAtIndexPath:)
    func
        tableView(
        _ tableView: UITableView,
        analyzerNameForRowAt indexPath: IndexPath
        ) -> String?
    @objc(tableView:analyzerNameForSection:)
    optional func
        tableView(
        _ tableView: UITableView,
        analyzerNameFor section: Int
        ) -> String?
}
