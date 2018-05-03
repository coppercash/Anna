
//  ANAManager.swift
//  Anna
//
//  Created by William on 01/07/2017.
//
//

import Foundation
import JavaScriptCore

@objc(ANANodeLocator)
public class
NodeLocator : NSObject
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
    
    //        return NodeLocator(
    //            ownerID: NSNumber(value: UInt(bitPattern: ownerID)),
    //            name: "ana-root"
    //        )
    class func
        root(owningBy ownerID :ObjectIdentifier) -> Self {
        return self.init(
            ownerID: UInt(bitPattern: ownerID),
            name: "ana-root"
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

//@objc protocol
//NodeLocatorJSExport : JSExport
//{
//    var
//    ownerID :NSNumber { get }
//    var
//    name :NSString { get }
//}
//extension
//NodeLocator : NodeLocatorJSExport {}

@objc protocol
    ScriptTrackerJSExport : JSExport
{
    func
        receive(analyticsResult :AnyObject)
}
class
    ScriptTracker : NSObject
{
    typealias
        Manager = ANAManager
    unowned let
    manager :Manager
    var
    tracker :Tracking?
    init(with manager :Manager) {
        self.manager = manager
    }
    func
        receive(analyticsResult: AnyObject) {
        self.tracker?.receive(
            analyticsResult: analyticsResult,
            dispatchedBy: self.manager
        )
    }
    func
        receive(analyticsError: Error) {
        self.tracker?.receive(
            analyticsError: analyticsError,
            dispatchedBy: self.manager
        )
    }
}
extension
ScriptTracker : ScriptTrackerJSExport {}

extension
    NSError
{
    convenience
    init(with jsValue :JSValue) {
        var
        userInfo = [String : String]()
        if let message = jsValue.forProperty("message").toString() {
            userInfo[NSLocalizedFailureReasonErrorKey] = message
        }
        if let stack = jsValue.forProperty("stack").toString() {
            userInfo[NSLocalizedDescriptionKey] = stack
        }
        self.init(
            domain: jsValue.forProperty("name").toString(),
            code: -1,
            userInfo: userInfo
        )
    }
}

@objc(ANADependency)
public class
    Dependency : CoreJS.Dependency
{
    public var
    moduleURL :URL! = nil
}

public class
    ANAManager :
    NSObject,
    ANAManaging
{
    var
    dependency :Dependency! = nil
    public convenience
    init(
        _ dependency :Dependency
        ) {
        self.init(Proto())
        self.dependency = dependency
    }
    
    let
    scriptQ = DispatchQueue(label: "anna.script")
    lazy var
    scriptTracker :ScriptTracker = {
        return ScriptTracker(with: self)
    }()
    
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
        handle(scriptResult :AnyObject)
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
        -> JSValue
    {
        if let manager = self.scriptManager {
            return manager
        }
        let
        context = self.resolvedScriptContext();
        let
        module = self.dependency.moduleURL!
        let
        dependency = self.dependency!
        dependency.handleException =
            { [weak self] (context, error) in
                guard let error = error else { return }
                self?.handle(scriptError: error)
        }
        let
        construct = context.run(
            module,
            with: dependency
            )!
        let
        receive : @convention(block) (AnyObject) -> Void = {
            [weak self] (result :AnyObject) in
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
        let
        manager = construct.call(withArguments: [
            (module.path as NSString).appendingPathComponent("task"),
            unsafeBitCast(inject, to: AnyObject.self),
            unsafeBitCast(receive, to: AnyObject.self)
            ]
            )!
        
        self.scriptManager = manager
        return manager
    }

    public typealias
        NodeLocator = Anna.NodeLocator
    func
        rootNodeLocator(
        ownerID :ObjectIdentifier
        ) -> NodeLocator
    {
        return NodeLocator.root(owningBy: ownerID)
//        return NodeLocator(
//            ownerID: NSNumber(value: UInt(bitPattern: ownerID)),
//            name: "ana-root"
//        )
    }
    
//    func
//        nodeLocator(
//        with name :String,
//        ownerID :ObjectIdentifier
//        ) -> NodeLocator
//    {
//        return NodeLocator(
//            ownerID: NSNumber(value: UInt(bitPattern: ownerID)),
//            name: (name as NSString)
//        )
//    }
    
    func
        registerNode(
        by locator :NodeLocator,
        under parentLocator :NodeLocator?
        )
    {
        let
        manager = self.resolvedScriptManager()
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
        manager = self.resolvedScriptManager()
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
    Properties = [String : String]
    func
        recordEvent(
        named name :String,
        with properties :Propertiez,
        locator :NodeLocator
        )
    {
        let
        manager = self.resolvedScriptManager()
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
    
    public func
        logSnapshot()
    {
        let
        manager = self.resolvedScriptManager()
        self.scriptQ.async {
            manager.invokeMethod(
                "logSnapshot",
                withArguments: []
            )
        }
    }
    
    public weak var
    tracker :Tracking? = nil
    
    typealias
        Proto = EasyManager
    let
    proto :Proto
    init(_ proto :Proto) {
        self.proto = proto
        self.trackers = ObjCTrackerConfigurator(proto.trackers)
    }
    
    public override convenience
    init() {
       self.init(Proto())
    }
    
    public let
    trackers :ANATrackerCollecting & ANATrackerConfiguring
    public static var
    sharedManager: ANAManager = ANAManager(Proto.shared)
    
    // MARK: - Load
    
    typealias
        Registrant = ANARegistering.Type
    typealias
        ClassPoint = ANAClassPoint
    typealias
        ClassPointBuilder = ANAClassPointBuilder
    func loadPoints(for registrant :Registrant) throws {
        guard (proto.root.classPoint(for: registrant) is ClassPoint) == false else { return }
        let
        builder = ClassPointBuilder(ClassPointBuilder.Proto(trackers: proto.trackers))
        builder.classBuffer = registrant
        let
        point = try builder.build()
        
        // Register the newly loaded point and all its super points
        //
        var current :ClassPoint? = point
        var currentBuilder :ClassPointBuilder? = builder
        while
            let point = current,
            let cls = currentBuilder?.classBuffer
        {
            point.parent = proto.root
            proto.root.setClassPoint(point, for: cls)
            current = point.superClassPoint
            currentBuilder = currentBuilder?.superClassPointBuilder
        }
        
        
    }
}

extension
ANAManager : ANAEventDispatching {
    func
        dispatchEvent(
        with seed: ANAPayloadCarrying & ANAPointMatchable & ANARegistrantCarrying
        ) {
        proto.queue.async {
            do {
                // Try to load points if they have not been loaded
                //
                try self.loadPoints(for: seed.registrant)
                try self.proto.dispatch(ObjCEventSeed(seed))
            }
            catch {
                try! self.proto.sendDefaultTrackers(error)
            }
        }
    }
}

extension
ANAClassPointBuilder : ANARegistrationRecording {
}
