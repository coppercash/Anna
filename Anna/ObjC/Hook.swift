//
//  Hook.swift
//  Anna_iOS
//
//  Created by William on 2018/5/2.
//

import Foundation

extension
    NSObject
{
    class func
        decorate(object :NSObject) {
        let
        stated = type(of: object)
        // Must be a KV-Observed object, which has method `_isKVOA`
        //
        guard
            let base = object_getClass(object),
            base != stated
            else { return }
        self.decorate(base)
        object_getClass(self).decorate(object_getClass(base))
    }
    class func
        decorate(_ decorated :AnyClass) {
        let
        decorating = self
        var
        methodCount = UInt32(0)
        guard let
            methods = class_copyMethodList(decorating, &methodCount)
            else { return }
        for
            index in 0..<numericCast(methodCount)
        {
            let
            method = methods[index],
            name = method_getName(method),
            imp = method_getImplementation(method)
            if imp == class_getMethodImplementation(decorated, name)
            { continue }
            class_addMethod(
                decorated,
                name,
                imp,
                method_getTypeEncoding(method)
            )
        }
        free(methods)
    }
}

public extension
    NSObject
{
    typealias
        Propertiez = [String : Any]
    @objc(ana_forwardRecordingEventNamed:withProperties:)
    func
        forwardRecordingEvent(
        named event:String,
        properties :Propertiez? = nil
        ) {
        var
        buffer :[TrampolineArgument.Key: Any] = [
            .event: event,
            ]
        if let
            properties = properties
        {
            buffer[.properties] = properties
        }
        let
        arguments = Set(buffer.map { TrampolineArgument($0, $1) })
        let
        key = #keyPath(NSObject.trampoline)
        self.willChangeValue(
            forKey: key,
            withSetMutation: .set,
            using: arguments
        )
        self.didChangeValue(
            forKey: key,
            withSetMutation: .set,
            using: arguments
        )
    }
    
    @objc(ana_trampoline) var
    trampoline :NSMutableSet! { return nil }
}

class
    TrampolineArgument : Hashable, CustomStringConvertible, CustomDebugStringConvertible
{
    var description: String { return "[\(self.key): \(self.value)]" }
    
    var debugDescription: String { return self.description }
    
    var hashValue: Int { return self.key.hashValue }
    
    static func
        == (lhs: TrampolineArgument, rhs: TrampolineArgument) -> Bool {
        return lhs.key == rhs.key
    }
    
    enum
        Key : Int
    {
        case event, properties
    }
    let
    key :Key,
    value :Any
    init(_ key :Key, _ value :Any) {
        self.key = key
        self.value = value
    }
}

class
    BaseObserver<Observee : NSObject> : NSObject, Reporting
{
    weak var
    recorder: Reporting.Recorder?
    
    weak var
    observee :Observee?
    let
    decorator :AnyClass?
    init(observee: Observee, decorator :AnyClass? = nil) {
        self.observee = observee
        self.decorator = decorator
        super.init()
        for (keyPath, options) in self.keyPaths {
            observee.addObserver(
                self,
                forKeyPath: keyPath,
                options: options,
                context: nil
            )
        }
        decorator?.decorate(object: observee)
    }
    
    deinit {
        if let observee = self.observee {
            for (keyPath, _) in self.keyPaths {
                observee.removeObserver(
                    self,
                    forKeyPath: keyPath
                )
            }
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
            event = change?.toEvent()
            else { return }
        recorder.recordEventOnPath(
            named: event.name,
            with: event.properties
        )
    }
    
    var
    keyPaths : [String: NSKeyValueObservingOptions] {
        return [
            #keyPath(NSObject.trampoline): .new,
        ]
    }
}



extension Dictionary
    where Key == NSKeyValueChangeKey, Value : Any
{
    func
        toEvent() -> Analyzer.Event? {
        guard let arguments = self[.newKey] as? NSSet
            else { return nil }
        var
        event :String? = nil,
        properties :Analyzer.Event.Properties? = nil
        for arg in arguments {
            guard let arg = arg as? TrampolineArgument else { continue }
            switch arg.key {
            case .event:
                event = arg.value as? String
            case .properties:
                properties = arg.value as? Analyzer.Event.Properties
            }
        }
        guard let
            name = event
            else { return nil }

        return Analyzer.Event(name: name, properties: properties)
    }
}