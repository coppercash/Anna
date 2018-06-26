//
//  SubAnalyzableObserver.swift
//  Anna_iOS
//
//  Created by William on 2018/6/10.
//

import Foundation

@objc(ANAAnalyzableObject)
public protocol
    AnalyzableObject : Analyzable
{
    static var
    subAnalyzableKeys : Set<String> { get }
}

class
    SubAnalyzableObserver : NSObject
{
    typealias
        Object = NSObject & AnalyzableObject
    unowned let
    object :Object
    let
    keys :Set<String>
    init(
        object :Object
        ) {
        self.object = object
        self.keys = type(of: object).subAnalyzableKeys
        super.init()
        self.observe()
    }
    deinit {
        self.deobserve()
    }
    func
        observe() {
        for
            key in self.keys
        {
            self.object.addObserver(
                self,
                forKeyPath: key,
                options: [.initial, .old, .new, .prior],
                context: nil
            )
        }
    }
    func
        deobserve() {
        for
            key in self.keys
        {
            self.object.removeObserver(
                self,
                forKeyPath: key
            )
        }
    }
    override func
        observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
        ) {
        guard
            let keyPath = keyPath,
            let change = change,
            let analyzer = self.object.analyzer as? Analyzer
            else { return }
        let
        isPrior = (change[.notificationIsPriorKey] as? Bool) ?? false,
        value = isPrior ? change[.oldKey] : change[.newKey],
        _update : (Analyzer, Analyzer, String, Int?) -> Void = (
            isPrior
                ? { (sub, _, _, _) in
                    sub.deactivate()
                    sub.detach()
                    }
                : { (sub, parent, keyPath, index) in
                    sub.enable(
                        under: analyzer,
                        key: keyPath,
                        index: index
                    )
            }
        ),
        update : (AnalyzerReadable, Analyzer, String, Int?) -> Void = {
            (analyzable, analyzer, keyPath, index) in
            guard let sub = analyzable.analyzer as? Analyzer
                else { return }
            _update(sub, analyzer, keyPath, index)
        }
        if let analyzable = value as? AnalyzerReadable {
            update(analyzable, analyzer, keyPath, nil)
        }
        else if let analyzables = value as? [AnalyzerReadable] {
            for (i, analyzable) in analyzables.enumerated() {
                update(analyzable, analyzer, keyPath, i)
            }
        }
    }
}
