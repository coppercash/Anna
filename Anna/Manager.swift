
//  Manager.swift
//  Anna
//
//  Created by William on 01/07/2017.
//
//

import Foundation
import JavaScriptCore

struct NodeID : Equatable
{
    let
    ownerID :UInt,
    keyPath :[String]?
    static func
    owned(
        by owner: AnyObject
        ) -> NodeID {
        return self.init(
            ownerID: UInt(bitPattern: ObjectIdentifier(owner)),
            keyPath: nil
        )
    }
    func
        isOwned(by object :AnyObject) -> Bool {
        return UInt(bitPattern: ObjectIdentifier(object)) == self.ownerID
    }
    var
    containsKeyPath :Bool {
        return self.keyPath != nil && self.keyPath!.count > 0
    }
    func
        appended(
        _ keyPath :[String]
        ) -> NodeID {
        var
        copied = self.keyPath ?? []
        copied.append(contentsOf: keyPath)
        return NodeID(
            ownerID: self.ownerID,
            keyPath: copied
        )
    }
    func
        appended(
        key :String,
        index :Int?
        ) -> NodeID {
        var
        keyPath = [key]
        if let
            index = index {
            keyPath.append("\(index)")
        }
        return self.appended(keyPath)
    }
    func
        toJSRepresentation() -> [Any] {
        var
        repr :[Any] = self.keyPath ?? []
        repr.insert(
            self.ownerID,
            at: 0
        )
        return repr
    }
}

@objc(ANADependency) @objcMembers
public class
    Dependency : CoreJS.Dependency
{
    public var
    moduleURL :URL? = nil,
    taskModuleURL :URL? = nil,
    config :[NSObject : AnyObject]? = nil,
    callbackQueue :DispatchQueue? = nil
}

@objc(ANAManager) @objcMembers
public class
    Manager : NSObject
{
    public var
    tracker :Tracking? = nil
    lazy var
    callbackQ = {
        return self.dependency.callbackQueue ?? DispatchQueue.main
    }()
    public let
    dependency :Dependency
    @objc(initWithDependency:)
    public init
        (
        _ dependency :Dependency
        ) {
        self.dependency = dependency
    }
    
    let
    scriptQ = DispatchQueue(label: "anna.script")
    var
    scriptContext :JSContext? = nil
    func
        resolvedScriptContext()
        -> JSContext
    {
        if let context = self.scriptContext {
            return context
        }
        let
        context = JSContext()!
        self.scriptContext = context
        return context
    }
    
    func
        handle(scriptResult :Any)
    {
        guard let
            tracker = self.tracker
            else { return }
        let
        callbackQ = self.callbackQ
        callbackQ.async {
            tracker.receive(
                analyticsResult: scriptResult,
                dispatchedBy: self
            )
        }
    }
    
    func
        handle(scriptError :JSValue)
    {
        guard let
            tracker = self.tracker
            else { return }
        let
        callbackQ = self.callbackQ
        callbackQ.async {
           tracker.receive(
                analyticsError: NSError(with: scriptError),
                dispatchedBy: self
            )
        }
    }
    
    var
    scriptManager :JSValue? = nil
    func
        resolvedScriptManager()
        throws -> JSValue
    {
        if let manager = self.scriptManager {
            return manager
        }
        let
        context = self.resolvedScriptContext();
        guard let
            module = self.dependency.moduleURL
            else { throw ScriptError.mainModuleURLNotSpecified }
        let
        dependency = self.dependency
        dependency.handleException =
            { [weak self] (context, error) in
                guard let error = error else { return }
                self?.handle(scriptError: error)
        }
        let
        construct = try context.run(
            module,
            with: dependency
            )
        let
        managerDependency = try self.resolvedManagerDependency()
        guard let
            manager = construct?.call(withArguments: [managerDependency])
            else { throw ScriptError.managerUnconstructable }
        
        self.scriptManager = manager
        return manager
    }
    func
        resolvedManagerDependency() throws -> [NSString : Any] {
        guard let
            task = self.dependency.taskModuleURL
            else { throw ScriptError.taskModuleURLNotSpecified }
        let
        context = self.resolvedScriptContext()
        let
        receive : @convention(block) (Any) -> Void = {
            [weak self] (result :Any) in
            self?.handle(scriptResult: result)
        },
        inject : @convention(block) (JSValue, JSValue) -> Void = {
            [weak context] (key :JSValue, value :JSValue) in
            guard let
                global = context?.globalObject
                else { return }
            if (value.isUndefined) {
                global.deleteProperty(key.toString())
            }
            else {
                global.setValue(value, forProperty: key.toString())
            }
        }
        var
        dependency :[NSString : Any] = [
            "taskModulePath": task.path,
            "inject": unsafeBitCast(inject, to: AnyObject.self),
            "receive": unsafeBitCast(receive, to: AnyObject.self),
        ]
        if let
            config = self.dependency.config
        {
            dependency["config"] = config
        }
        return dependency
    }
    func
        registerNode(
        by identifier :NodeID,
        under parentID :NodeID?,
        name :String,
        index :Int?,
        namespace :String? = nil,
        attributes :Properties? = nil
        ) throws {
        let
        manager = try self.resolvedScriptManager()
        self.scriptQ.async {
            let
            null = NSNull(),
            arguments :[Any] = [
                identifier.toJSRepresentation(),
                parentID?.toJSRepresentation() ?? null,
                name,
                index ?? null,
                namespace ?? null,
                attributes ?? null
            ]
            manager.invokeMethod(
                "registerNode",
                withArguments: arguments
            )
        }
    }
    func
        deregisterNodes(
        by identifier :NodeID
        ) throws {
        let
        manager = try self.resolvedScriptManager()
        self.scriptQ.async {
            manager.invokeMethod(
                "deregisterNodes",
                withArguments: [
                    identifier.toJSRepresentation()
                ]
            )
        }
    }
    typealias
        Properties = [String : Any]
    func
        recordEvent(
        named name :String,
        with properties :Propertiez?,
        onNodeBy identifier :NodeID
        ) throws {
        let
        manager = try self.resolvedScriptManager()
        self.scriptQ.async {
            let
            null = NSNull(),
            arguments :[Any] = [
                name,
                properties ?? null,
                identifier.toJSRepresentation()
            ]
            manager.invokeMethod(
                "recordEvent",
                withArguments: arguments
            )
        }
    }
    @objc
    public func
        logSnapshot() throws {
        let
        manager = try self.resolvedScriptManager()
        self.scriptQ.async {
            manager.invokeMethod(
                "logSnapshot",
                withArguments: []
            )
        }
    }
}

enum
    ScriptError : Error
{
    case taskModuleURLNotSpecified
    case mainModuleURLNotSpecified
    case managerUnconstructable
}
