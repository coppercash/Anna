//
//  KVObserver.swift
//  Anna_iOS
//
//  Created by William on 2018/5/3.
//

import Foundation

class
    KVObserver : NSObject,  Reporting
{
    weak var
    recorder: Reporting.Recorder? = nil {
        didSet {
            guard let observee = self.observee else { return }
            if let _ = self.recorder {
                observee.addObserver(
                    self,
                    forKeyPath: self.keyPath,
                    options: [.old, .new],
                    context: nil
                )
            }
            else {
                observee.removeObserver(
                    self,
                    forKeyPath: self.keyPath
                )
            }
        }
    }
    
    weak var
    observee :NSObject?
    let
    keyPath :String
    init(
        _ observee :NSObject,
        _ keyPath :String
        ) {
        self.observee = observee
        self.keyPath = keyPath
        super.init()
    }
    deinit {
        if
            let _ = self.recorder,
            let observee = self.observee
        {
            observee.removeObserver(
                self,
                forKeyPath: self.keyPath
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
            let
            recorder = self.recorder,
            let
            keyPath = keyPath,
            let
            change = change,
            let
            after = change[.newKey]
            else { return }
        let
        name = "ana-value-updated"
        let
        properties = [
            "key-path" : keyPath,
            "value" : after
        ]
        guard let before = change[.oldKey] else {
            recorder.recordEventOnPath(
                named: name,
                with: properties
            )
            return
        }
        if
            let before = before as? NSObject,
            let after = after as? NSObject,
            before == after
        { return }
        recorder.recordEventOnPath(
            named: name,
            with: properties
        )
    }
}
