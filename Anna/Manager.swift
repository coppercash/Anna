
//  Manager.swift
//  Anna
//
//  Created by William on 01/07/2017.
//
//

import Foundation
import JavaScriptCore

class
NodeLocator 
{
    let
    ownerID :UInt,
    name :String
    init(
        ownerID :UInt,
        name :String
        ) {
        self.ownerID = ownerID
        self.name = name
    }
    
    class func
        root(
        ownerID :ObjectIdentifier,
        name :String
        ) -> Self {
        return self.init(
            ownerID: UInt(bitPattern: ownerID),
            name: name
        )
    }
    
//    weak var
//    parent :NodeLocator? = nil
//    var
//    children :[String: NodeLocator] = [:]
    func
        forked(
        with name :String,
        ownerID :ObjectIdentifier
        ) -> NodeLocator {
//        let
//        parent = self
//
//        if let child = parent.children[name]
//        { return child }
        
        let
        child = NodeLocator(
            ownerID: UInt(bitPattern: ownerID),
            name: name
        )
        
//        child.parent = parent
//        parent.children[name] = child
        
        return child
    }
    
//    func
//        delete() {
//        guard let parent = self.parent
//            else { return }
//        parent.children.removeValue(forKey: self.name)
//    }
    
//    deinit {
//        print(self.name)
//    }
}


@objc(ANADependency) @objcMembers
public class
    Dependency : CoreJS.Dependency
{
    public var
    moduleURL :URL? = nil
}

@objc(ANAManager) @objcMembers
public class
    Manager : NSObject
{
    public var
    tracker :Tracking? = nil
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
        self.tracker?.receive(
            analyticsResult: scriptResult,
            dispatchedBy: self
        )
    }
    
    func
        handle(scriptError :JSValue)
    {
        self.tracker?.receive(
            analyticsError: NSError(with: scriptError),
            dispatchedBy: self
        )
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
        guard let
            manager = construct?.call(withArguments: [
                (module.path as NSString).appendingPathComponent("task"),
                unsafeBitCast(inject, to: AnyObject.self),
                unsafeBitCast(receive, to: AnyObject.self)
                ]
            )
            else { throw ScriptError.managerUnconstructable }
        
        self.scriptManager = manager
        return manager
    }

    typealias
        NodeLocator = Anna.NodeLocator
    func
        rootNodeLocator(
        ownerID :ObjectIdentifier,
        name :String
        ) -> NodeLocator
    {
        return NodeLocator.root(
            ownerID: ownerID,
            name: name
        )
    }
    
    func
        registerNode(
        by locator :NodeLocator,
        under parentLocator :NodeLocator?
        )
    {
        let
        manager = try! self.resolvedScriptManager()
        self.scriptQ.async {
            let
            arguments :[Any]
            if let
                parentLocator = parentLocator
            {
                arguments = [
                    locator.ownerID,
                    locator.name,
                    parentLocator.ownerID,
                    parentLocator.name
                ]
            }
            else {
                arguments = [
                    locator.ownerID,
                    locator.name
                ]
            }
            manager.invokeMethod(
                "registerNodeRaw",
                withArguments: arguments
            )
        }
    }
    
    func
        deregisterNode(
        by locator :NodeLocator
        ) {
        let
        manager = try! self.resolvedScriptManager()
        self.scriptQ.async {
            manager.invokeMethod(
                "deregisterNodeRaw",
                withArguments: [
                    locator.ownerID,
                    locator.name
                ]
            )
        }
    }
    
    typealias
    Properties = [String : Any]
    func
        recordEvent(
        named name :String,
        with properties :Propertiez,
        locator :NodeLocator
        )
    {
        let
        manager = try! self.resolvedScriptManager()
        self.scriptQ.async {
            manager.invokeMethod(
                "recordEventRaw",
                withArguments: [
                    name,
                    properties,
                    locator.ownerID,
                    locator.name
                ]
            )
        }
    }
    
    @objc
    public func
        logSnapshot()
    {
        let
        manager = try! self.resolvedScriptManager()
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
    case mainModuleURLNotSpecified
    case managerUnconstructable
}
