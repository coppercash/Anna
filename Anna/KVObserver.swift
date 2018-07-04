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
    observeeRef :NSValue
    var
    isObserving = false
    var
    observee :Observee {
        return self.observeeRef.nonretainedObjectValue as! Observee
    }
    init(
        keyPaths :[String: NSKeyValueObservingOptions],
        observee :Observee
        ) {
        self.keyPaths = keyPaths
        self.observeeRef = NSValue(nonretainedObject: observee)
    }
    deinit {
        self.detach()
    }
    func
        observe(_ observee :Observee) {
        guard self.isObserving == false else { return }
        self.isObserving = true
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
        guard self.isObserving else { return }
        for (keyPath, _) in self.keyPaths {
            observee.removeObserver(
                self,
                forKeyPath: keyPath
            )
        }
        self.isObserving = false
    }
    func
        detach() {
        let observee = self.observee
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
            let observee = self.observee
            if let _ = self.recorder {
                self.deobserve(observee)
            }
        }
        didSet {
            let observee = self.observee 
            if let _ = self.recorder {
                self.observe(observee)
            }
        }
    }
    override func
        detach() {
        super.detach()
        self.recorder = nil
    }
}

class
    KVObserver<Observee> : ReportingObserver<Observee>
    where Observee : NSObject
{
    init(
        keyPath :String,
        observee :Observee
        ) {
        super.init(
            keyPaths: [keyPath: [.initial, .new, .old]],
            observee: observee
        )
    }
    override func
        observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
        ) {
        guard
            keyPath == self.keyPaths.first?.key
            else {
                return super.observeValue(
                    forKeyPath: keyPath,
                    of: object,
                    change: change,
                    context: context
                )
        }
        guard
            let
            keyPath = keyPath,
            let
            change = change,
            let
            after = change[.newKey]
            else { return }
        let
        name = "ana-updated"
        let
        properties = [
            "key-path" : keyPath,
            "value" : after
        ]
        guard let before = change[.oldKey] else {
            self.recorder?.recordEvent(
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
        self.recorder?.recordEvent(
            named: name,
            with: properties
        )
    }
}
