//
//  Hook.swift
//  Anna_iOS
//
//  Created by William on 2018/5/2.
//

import Foundation

@objc(ANAReporting)
public protocol
    Reporting
{
    typealias
        Recorder = Recording
    weak var
    recorder :Recorder? { get set }
}

@objc(ANARecording)
public protocol
    Recording
{
    typealias
        Properties = NSObject.Propertiez
    func
        recordEventOnPath(
        named name :String,
        with properties :Properties?
    )
}

@objc(ANAHookable)
public protocol
    Hookable
{
    @objc(ana_tokenByAddingObserver)
    func
        tokenByAddingObserver() -> Reporting
    @objc(ana_tokenByAddingOwnedObserver)
    func
        tokenByAddingOwnedObserver() -> Reporting
}

extension
    NSObject
{
    @objc(ana_decorateObject:)
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
        object_getClass(self)?.decorate(object_getClass(base)!)
    }
    @objc(ana_decorate:)
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

extension
    NSObject
{
    public typealias
        Propertiez = [String : Any]
    @objc(ana_forwardRecordingEventNamed:withProperties:)
    public func
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
    DecoratingObserver<Observee> : ReportingObserver<Observee>
    where Observee : NSObject
{
    let
    decorators :[AnyClass]
    init(
        decorators :[AnyClass],
        keyPaths :[String: NSKeyValueObservingOptions],
        observee :Observee,
        owned :Bool = false
        ) {
        self.decorators = decorators
        super.init(
            keyPaths: keyPaths,
            observee: observee,
            owned: owned
        )
    }
    override func
        observe(_ observee: Observee) {
        super.observe(observee)
        for decorator in self.decorators {
            decorator.decorate(object: observee)
        }
    }
    override func
        observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
        ) {
        guard let event = change?.toEvent() else {
            return super.observeValue(
                forKeyPath: keyPath,
                of: object,
                change: change,
                context: context
            )
        }
        self.recorder?.recordEventOnPath(
            named: event.name,
            with: event.properties
        )
    }
}

class
    HookingObserver<Observee> : DecoratingObserver<Observee>
    where Observee : NSObject
{
    required
    init(
        observee :Observee,
        owned :Bool
        ) {
        let
        clazz = type(of: self)
        super.init(
            decorators: clazz.decorators,
            keyPaths: clazz.keyPaths,
            observee: observee,
            owned: owned
        )
    }
    class var
    keyPaths :[String: NSKeyValueObservingOptions] {
        return [
            #keyPath(NSObject.trampoline): .new,
        ]
    }
    class var
    decorators :[AnyClass] { return [] }
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
