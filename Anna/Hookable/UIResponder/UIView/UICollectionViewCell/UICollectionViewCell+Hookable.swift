//
//  UICollectionViewCell+Hookable.swift
//  Anna_iOS
//
//  Created by William on 2018/5/26.
//

import UIKit

extension
    UICollectionViewCell
{
    public override func
        tokenByAddingObserver() -> Reporting {
        return UICollectionViewCellObserver(observee: self, owned: false)
    }
    public override func
        tokenByAddingOwnedObserver() -> Reporting {
        return UICollectionViewCellObserver(observee: self, owned: true)
    }
}

class
    UICollectionViewCellObserver<Observee> : UIViewObserver<Observee>
    where Observee : UICollectionViewCell
{
    class override var
    decorators :[AnyClass] {
        return super.decorators + [ANAUICollectionViewCell.self]
    }
    override func
        observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
        ) {
        #if swift(>=4.1)
            let
            eventName = change?.toEvent()?.name
        #else
            guard let
                eventName = change?.toEvent()?.name
                else
            {
                return super.observeValue(
                    forKeyPath: keyPath,
                    of: object,
                    change: change,
                    context: context
                )
            }
        #endif
        switch eventName {
        case String(describing: #selector(UICollectionViewDelegate.collectionView(_:willDisplay:forItemAt:))):
            self.visibilityRecorder.record(true)
        case String(describing: #selector(UICollectionViewDelegate.collectionView(_:didEndDisplaying:forItemAt:))):
            self.visibilityRecorder.record(false)
        case String(describing: #selector(UICollectionViewDelegate.collectionView(_:didSelectItemAt:))):
            self.recorder?.recordEvent(
                named: "did-select",
                with: nil
            )
        default:
            return super.observeValue(
                forKeyPath: keyPath,
                of: object,
                change: change,
                context: context
            )
        }
    }
}

extension
    UICollectionViewCell
{
    @objc(ana_prepareAnalyzerForReuse)
    public func
        prepareAnalyzerForReuse() {
        guard let
            analyzer = (self as? AnalyzerReadable)?.analyzer as? Analyzer
            else { return }
        do {
            try analyzer.deactivate()
        } catch let error {
            assertionFailure(error.localizedDescription)
        }
    }
    open override func
        parentConstitutor(
        isOwning: UnsafeMutablePointer<Bool>
        ) -> FocusPathConstituting? {
        return nil
    }
}
