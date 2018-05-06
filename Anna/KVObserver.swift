//
//  KVObserver.swift
//  Anna_iOS
//
//  Created by William on 2018/5/3.
//

import Foundation

class
    KeyPathsObserver<Observee> : NSObject
    where Observee : NSObject
{
    let
    keyPaths :[String: NSKeyValueObservingOptions],
    owner :NSValue?
    weak var
    observee :Observee?
    init(
        keyPaths :[String: NSKeyValueObservingOptions],
        observee :Observee,
        owned :Bool 
        ) {
        self.keyPaths = keyPaths
        self.observee = observee
        self.owner = owned ? NSValue.init(nonretainedObject: observee) : nil
    }
    func
        observe(_ observee :Observee) {
        for (keyPath, options) in self.keyPaths {
            observee.addObserver(
                self,
                forKeyPath: keyPath,
                options: options,
                context: nil
            )
        }
    }
    func
        deobserve(_ observee :Observee) {
        for (keyPath, _) in self.keyPaths {
            observee.removeObserver(
                self,
                forKeyPath: keyPath
            )
        }
    }
    deinit {
        guard let
            observee = self.observee ??
                (self.owner?.nonretainedObjectValue as? Observee)
            else { return }
        self.deobserve(observee)
    }
    
    override func
        observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
        ) { }
}

class
    ReportingObserver<Observee> : KeyPathsObserver<Observee>, Reporting
    where Observee : NSObject
{
    weak var
    recorder: Reporting.Recorder? {
        willSet {
            guard let observee = self.observee else { return }
            if let _ = self.recorder {
                self.deobserve(observee)
            }
        }
        didSet {
            guard let observee = self.observee else { return }
            if let _ = self.recorder {
                self.observe(observee)
            }
        }
    }
}

class
    KVObserver : NSObject, Reporting
{
    weak var
    recorder: Reporting.Recorder? = nil {
        didSet {
            guard let observee = self.observee else { return }
            if let _ = self.recorder {
                observee.addObserver(
                    self,
                    forKeyPath: self.keyPath,
                    options: [.old, .new, .initial],
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
