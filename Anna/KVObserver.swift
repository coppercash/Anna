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
    keyPaths :[String: NSKeyValueObservingOptions]
    var
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
//        self.owner = owned ? NSValue.init(nonretainedObject: observee) : nil
        self.owner = NSValue.init(nonretainedObject: observee)
    }
    deinit {
        self.detach()
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
    func
        detach() {
        if let observee = self.observeeBeingDeobserved() {
            self.deobserve(observee)
            self.observee = nil
            self.owner = nil
        }
    }
    func
        observeeBeingDeobserved() -> Observee? {
        if let owner = self.owner {
            return owner.nonretainedObjectValue as? Observee
        }
        else {
            return self.observee
        }
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
        observee :Observee,
        owned :Bool
        ) {
        super.init(
            keyPaths: [keyPath: [.initial, .new, .old]],
            observee: observee,
            owned: owned
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
