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
        guard
            let
            analyzable = cell as? AnalyzerReadable,
            let
            dummy = analyzable.analyzer as? Analyzer
        else { return cell }

        let
        owner = tableView as! AnalyzerReadable,
        table = owner.analyzer as! Analyzer
        let
        parent :Analyzer
        if let
            delegate = tableView.delegate as? AnalyzableGroupedTableViewDelegate,
            let
            identifier = delegate.tableView(tableView, analyzableGroupIdentifierForRowAt: indexPath)
        {
            parent = table.resolvedChildAnalyzer(
                named: String(describing: identifier),
                with: identifier
            )
        }
        else {
            parent = table
        }
        let
        row = parent.resolvedChildAnalyzer(
            named: dummy.name,
            with: indexPath
        )
        dummy.startForwardingEvents(to: row)
        dummy.flushDeferredEvents(to: row)

        return cell
    }
}

@objc(ANAAnalyzableGroupedTableViewDelegate)
public protocol
    AnalyzableGroupedTableViewDelegate
{
    // TODO: Remove
//    @objc(tableView:analyzerNameForRowAtIndexPath:)
//    func
//        tableView(
//        _ tableView: UITableView,
//        analyzerNameForRowAt indexPath: IndexPath
//        ) -> String?
//    @objc(tableView:analyzerNameForSection:)
//    optional func
//        tableView(
//        _ tableView: UITableView,
//        analyzerNameFor section: Int
//        ) -> String?
    @objc(tableView:analyzableGroupIdentifierForRowAtIndexPath:)
    func
        tableView(
        _ tableView: UITableView,
        analyzableGroupIdentifierForRowAt indexPath: IndexPath
        ) -> AnyHashable?
}
