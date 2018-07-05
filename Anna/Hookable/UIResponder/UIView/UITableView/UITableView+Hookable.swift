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
        return UITableViewObserver(observee: self)
    }
}

extension
    UITableView
{
    @objc(ana_reloadData)
    public func
        ana_reloadData() {
        guard let
            analyzer = (self as? AnalyzerReadable)?.analyzer as? Analyzer
            else { return }
        for
            i in 0..<(self.dataSource?.numberOfSections?(in: self) ?? 1)
        {
            analyzer.removeSubordinary(for: i)
        }
    }
    @objc(ana_reloadSections:withRowAnimation:)
    public func
        ana_reloadSections(
        _ sections: IndexSet,
        with animation: UITableViewRowAnimation
        ) {
        guard let
            analyzer = (self as? AnalyzerReadable)?.analyzer as? Analyzer
            else { return }
        for
            i in sections
        {
            analyzer.removeSubordinary(for: i)
        }
    }
}

struct
    UITableViewOutSourceKeys : OutSourcingKeys
{
    static var
    _dataSource :UInt8 = 0,
    _delegate :UInt8 = 0
    static var
    dataSourceKey :UnsafeRawPointer { return withUnsafePointer(to: &_dataSource) { UnsafeRawPointer($0) } }
    static var
    delegateSourceKey :UnsafeRawPointer { return withUnsafePointer(to: &_delegate) { UnsafeRawPointer($0) } }
}

extension
    UITableView : OutSourcingView
{}

class
    UITableViewObserver<Observee> : BaseCollectionViewObserver<
    Observee,
    UITableViewDataSourceProxy,
    UITableViewDelegateProxy,
    UITableViewOutSourceKeys,
    ANAUITableView
    >
    where Observee : UITableView
{}

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
        let cell = self.target.tableView(
            tableView,
            cellForRowAt: indexPath
        )
        if
            let
            row = cell as? AnalyzerReadable,
            let
            table = tableView as? AnalyzerReadable & SectionAnalyzable
        {
            _configure(
                cell: row,
                in: table,
                at: indexPath
            )
        }
        return cell
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
        cell.forwardRecordingEvent(
            named: String(describing: #selector(tableView(_:willDisplay:forRowAt:)))
        )
        self.target.tableView?(
            tableView,
            willDisplay: cell,
            forRowAt: indexPath
        )
    }
    func
        tableView(
        _ tableView: UITableView,
        didEndDisplaying cell: UITableViewCell,
        forRowAt indexPath: IndexPath
        ) {
        cell.forwardRecordingEvent(
            named: String(describing: #selector(tableView(_:didEndDisplaying:forRowAt:)))
        )
        self.target.tableView?(
            tableView,
            didEndDisplaying: cell,
            forRowAt: indexPath
        )
    }
    func
        tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
        ) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.forwardRecordingEvent(
                named: String(describing: #selector(tableView(_:didSelectRowAt:)))
            )
            if let analyzer = (cell as? AnalyzerReadable)?.analyzer as? FocusHandling {
                analyzer.handleFocused(cell)
            }
        }
        self.target.tableView?(
            tableView,
            didSelectRowAt: indexPath
        )
    }
}

extension
    UITableView : SectionAnalyzable
{
    typealias
        Cell = UITableViewCell
    func
        analyticName(
        for section: Int
        ) -> String? {
        guard let
            delegate = self.delegate as? SectionAnalyzableTableViewDelegate,
            let
            name = delegate.tableView(
                self as! UITableView & AnalyzerReadable,
                analyticNameFor: section
            )
            else { return nil }
        return name
    }
    func
        didCreate(
        _ analyzer :Analyzing,
        for section: Int
        ) {
        guard let
            delegate = self.delegate as? SectionAnalyzableTableViewDelegate
            else { return }
        delegate.tableView?(
            self as! UITableView & AnalyzerReadable,
            didCreate: analyzer,
            for: section
        )
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
