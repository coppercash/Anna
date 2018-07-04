//
//  UICollectionView+Hookable.swift
//  Anna_iOS
//
//  Created by William on 2018/5/26.
//

import UIKit

extension
    UICollectionView
{
    public override func
        tokenByAddingObserver() -> Reporting {
        return UICollectionViewObserver(observee: self)
    }
}

extension
    UICollectionView
{
    @objc(ana_reloadData)
    public func
        ana_reloadData() {
        guard let
            analyzer = (self as? AnalyzerReadable)?.analyzer as? Analyzer
            else { return }
        for
            i in 0..<(self.dataSource?.numberOfSections?(in: self) ?? 0)
        {
            analyzer.removeSubordinary(for: i)
        }
    }
    @objc(ana_reloadSections:)
    public func
        ana_reloadSections(
        _ sections: IndexSet
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

class
    UICollectionViewObserver<Observee> : UIViewObserver<Observee>
    where Observee : UICollectionView
{
    var
    dataSource :UICollectionViewDataSourceProxy? = nil,
    delegate :UICollectionViewDelegateProxy? = nil
    override func
        observe(_ observee: Observee) {
        super.observe(observee)
        let
        dataSource = observee.dataSource as! (UICollectionViewDataSource & NSObject)
        self.dataSource = UICollectionViewDataSourceProxy(dataSource)
        observee.dataSource = self.dataSource
        
        let
        delegate = observee.delegate as! (UICollectionViewDelegate & NSObject)
        self.delegate = UICollectionViewDelegateProxy(delegate)
        observee.delegate = self.delegate
    }
    override func
        deobserve(_ observee: Observee) {
        super.deobserve(observee)
        if let delegate = self.delegate?.target {
            // Reset `UICollectionView._delegateHas`
            //
            observee.delegate = delegate
        }
        if let dataSource = self.dataSource?.target {
            // Reset `UICollectionView._dataSourceHas`
            //
            observee.dataSource = dataSource
        }
    }
    class override var
    decorators :[AnyClass] {
        return super.decorators + [ANAUICollectionView.self]
    }
}

class
    UICollectionViewDelegateProxy : Proxy<UICollectionViewDelegate>, UICollectionViewDelegate
{
    func
        collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
        ) {
        cell.forwardRecordingEvent(
            named: String(
                describing:#selector(
                    collectionView(_:willDisplay:forItemAt:)
                )
            )
        )
        self.target?.collectionView?(
            collectionView,
            willDisplay: cell,
            forItemAt: indexPath
        )
    }
    func
        collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
        ) {
        cell.forwardRecordingEvent(
            named: String(
                describing:#selector(
                    collectionView(_:didEndDisplaying:forItemAt:)
                )
            )
        )
        self.target?.collectionView?(
            collectionView,
            didEndDisplaying: cell,
            forItemAt: indexPath
        )
    }
    func
        collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
        ) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            cell.forwardRecordingEvent(
                named: String(
                    describing: #selector(
                        collectionView(_:didSelectItemAt:)
                    )
                )
            )
            if let analyzer = (cell as? AnalyzerReadable)?.analyzer as? FocusHandling {
                analyzer.handleFocused(cell)
            }
        }
        self.target?.collectionView?(
            collectionView,
            didSelectItemAt: indexPath
        )
    }
}

extension
    UICollectionView : SectionAnalyzable
{
    func
        analyticName(
        for section: Int
        ) -> String? {
        guard let
            delegate = self.delegate as? SectionAnalyzableCollectionViewDelegate,
            let
            name = delegate.collectionView(
                self as! UICollectionView & AnalyzerReadable,
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
            delegate = self.delegate as? SectionAnalyzableCollectionViewDelegate
            else { return }
        delegate.collectionView?(
            self as! UICollectionView & AnalyzerReadable,
            didCreate: analyzer,
            for: section
        )
    }
}

class
    UICollectionViewDataSourceProxy : Proxy<UICollectionViewDataSource>, UICollectionViewDataSource
{
    func
        collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
        ) -> Int {
        return self.target?.collectionView(
            collectionView,
            numberOfItemsInSection: section
        ) ?? 0
    }
    func
        collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
        ) -> UICollectionViewCell {
        guard let cell = self.target?.collectionView(
            collectionView,
            cellForItemAt: indexPath
            )
            else { return UICollectionViewCell(frame: CGRect.zero) }
        if
            let
            row = cell as? AnalyzerReadable,
            let
            table = collectionView as? AnalyzerReadable & SectionAnalyzable
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

@objc(ANASectionAnalyzableCollectionViewDelegate)
public protocol
    SectionAnalyzableCollectionViewDelegate
{
    @objc(collectionView:didCreateAnalyzer:forSection:)
    optional func
        collectionView(
        _ collectionView: UICollectionView & AnalyzerReadable,
        didCreate analyzer :Analyzing,
        for section :Int
        ) -> Void
    @objc(collectionView:analyticNameForSection:)
    func
        collectionView(
        _ collectionView: UICollectionView & AnalyzerReadable,
        analyticNameFor section :Int
        ) -> String?
}
