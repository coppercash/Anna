
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
    
    #if !swift(>=4.1)
    static func
        ==(
        lhs: NodeID,
        rhs: NodeID
        ) -> Bool {
        return lhs.ownerID == rhs.ownerID
        && ((lhs.keyPath == nil && rhs.keyPath == nil)
            || (lhs.keyPath != nil && rhs.keyPath != nil && lhs.keyPath! == rhs.keyPath!)
        )
    }
    #endif
}

@objc(ANADependency) @objcMembers
public class
    Dependency : NSObject
{
    public var
    fileManager :CoreJS.FileManaging? = nil,
    logger :CoreJS.Logging? = nil,
    exceptionHandler :CoreJS.Dependency.ExceptionHandler? = nil,
    coreModuleURL :URL? = nil,
    coreJSModuleURL :URL? = nil
    
    internal func
        coreDependency() -> CoreJS.Dependency {
        let
        dependency = self,
        dep = CoreJS.Dependency()
        dep.fileManager = dependency.fileManager
        dep.logger = dependency.logger
        dep.exceptionHandler = dependency.exceptionHandler
        dep.moduleURL = dependency.coreJSModuleURL
        return dep
    }
}

@objc(ANADelegate)
public protocol
    Delegate : Tracking
{}

@objc(ANAManager) @objcMembers
public class
    Manager : NSObject
{
    public let
    moduleURL: URL,
    config :Dictionary<String, Any>?,
    dependency :Dependency?
    @objc(initWithModuleURL:config:dependency:)
    public init
        (
        moduleURL: URL,
        config :Dictionary<String, Any>? = nil,
        dependency :Dependency? = nil
        ) {
        self.moduleURL = moduleURL
        self.config = config
        self.dependency = dependency
    }
    
    public var
    delegate :Delegate? = nil,
    delegateQueue :DispatchQueue = .main

    let
    scriptQ = DispatchQueue(label: "anna.script")
    lazy var
    scriptContext :JSContext = JSContext()
    func
        handle(scriptResult :Any)
    {
        guard let
            tracker = self.delegate
            else { return }
        let
        callbackQ = self.delegateQueue
        callbackQ.async {
            tracker.manager(
                self,
                didSend: scriptResult
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
        context = self.scriptContext,
        moduleURL = self.moduleURL,
        dependency = self.resolvedCoreDependency(),
        arguments = self.resolvedManagerArguments()
        try context.setup(with: dependency)
        guard
            let
            construct = context.require(
                moduleURL
                    .appendingPathComponent("index")
                    .appendingPathExtension("js")
                    .path
            ),
            let
            manager = construct.call(
                withArguments: arguments
            )
            else { throw ScriptError.managerUnconstructable }
        
        self.scriptManager = manager
        return manager
    }
    func
        resolvedCoreDependency() -> CoreJS.Dependency {
        let
        moduleURL = self.moduleURL,
        dependency = self.dependency,
        annaURL = dependency?.coreModuleURL ??
            Bundle.main
                .bundleURL
                .appendingPathComponent("anna")
                .appendingPathExtension("bundle"),
        dep = dependency?.coreDependency() ?? CoreJS.Dependency()
        dep.nodePathURLs = [moduleURL]
        dep.globalModules = [
            "anna" : annaURL
        ]
        return dep
    }
    func
        resolvedManagerArguments() -> [Any] {
        let
        receive : @convention(block) (Any) -> Void = {
            [weak self] (result :Any) in
            self?.handle(scriptResult: result)
        },
        config = self.config ?? [:]
        let
        arguments = [
            unsafeBitCast(receive, to: AnyObject.self),
            config
        ] as [Any]
        return arguments
    }
    func
        registerNode(
        by identifier :NodeID,
        under parentID :NodeID?,
        name :String,
        index :Int?,
        namespace :String? = nil,
        attributes :Attributes? = nil
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
        Attributes = [String : Any]
    func
        recordEvent(
        named name :String,
        with properties :Attributes?,
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
    case managerUnconstructable
}
