
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
    ownerID :NSNumber,
    name :NSString
    init(
        ownerID :NSNumber,
        name :NSString
        ) {
        self.ownerID = ownerID
        self.name = name
    }
}

@objc protocol
NodeLocatorJSExport : JSExport
{
    var
    ownerID :NSNumber { get }
    var
    name :NSString { get }
}
extension
NodeLocator : NodeLocatorJSExport {}

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
    Dependency : NSObject
{
    public var
    fileManager :FileManaging! = nil,
    workDirecotryURL :URL! = nil,
    coreJSScriptURL :URL! = nil
}

public class
    ANAManager :
    NSObject,
    ANAManaging
{
    var
    fileManager :FileManaging! = nil,
    dependency :Dependency! = nil
    public convenience
    init(
        _ dependency :Dependency
        ) {
        self.init(Proto())
        self.fileManager = dependency.fileManager
        self.dependency = dependency
    }
    
    public typealias
    NodeLocator = Anna.NodeLocator
    func
        nodeLocator(
        with name :String,
        ownerID :ObjectIdentifier
        ) -> NodeLocator
    {
        return NodeLocator(
            ownerID: NSNumber(value: UInt(bitPattern: ownerID)),
            name: (name as NSString)
        )
    }
    
    let
    scriptQ = DispatchQueue(label: "anna.script")
    lazy var
    scriptTracker :ScriptTracker = {
        return ScriptTracker(with: self)
    }()
    
    var
    scriptContext :CoreJS.Context? = nil
    func
        resolvedScriptContext()
        -> CoreJS.Context
    {
        if let context = self.scriptContext {
            return context
        }
        let
        context = CoreJS.Context.run(
            in: self.dependency.workDirecotryURL,
            with: self.fileManager,
            exceptionHandler:
            { [weak self] (context, error) in
                guard let error = error else { return }
                self?.handle(scriptError: error)
            }
            )!
        self.scriptContext = context
        return context
    }
    
    func
        handle(scriptResult :JSValue)
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
        callback : @convention(block) (JSValue) -> Void = {
            [weak self] (result :JSValue) in
            self?.handle(scriptResult: result)
        };
        let
        context = self.resolvedScriptContext();
        let
        manager = context
            .evaluateScript("CoreJS._require('anna').Anna.withTrack")
            .call(withArguments: [
                unsafeBitCast(callback, to: AnyObject.self)
                ]
            )!;
        print(context.evaluateScript("Object.keys").call(withArguments: [manager]).toString())
        return manager
    }

    func
        registerRootNode(
        by locator :NodeLocator
        )
    {
        self.scriptQ.async {
            self.resolvedScriptManager().invokeMethod(
                "registerRootNode",
                withArguments: [
                    locator.ownerID
                ]
            )
        }
    }

    func
        registerNode(
        by locator :NodeLocator,
        under parentLocator :NodeLocator
        )
    {
        self.scriptQ.async {
            self.resolvedScriptManager().invokeMethod(
                "registerNode",
                withArguments: [
                    locator.ownerID,
                    locator.name,
                    parentLocator.ownerID,
                    parentLocator.name
                ]
            )
        }
    }
    
    func
        recordEvent(
        named name :String,
        with properties :[String: AnyObject],
        locator :NodeLocator
        )
    {
        self.scriptQ.async {
            self.resolvedScriptManager().invokeMethod(
                "recordEvent",
                withArguments: [
                    name,
                    properties,
                    locator.ownerID,
                    locator.name
                ]
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
