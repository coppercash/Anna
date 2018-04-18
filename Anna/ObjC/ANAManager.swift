
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

public class
    ANAManager :
    NSObject,
    ANAManaging
{
    var
    fileManager :FileManaging! = nil,
    mainScriptURL :URL! = nil
    public convenience
    init(
        mainScriptURL :URL,
        fileManager :FileManaging
        ) {
        self.init(Proto())
        self.mainScriptURL = mainScriptURL
        self.fileManager = fileManager
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
        dependencies = CoreJS.Dependencies()
        dependencies.fileManager = self.fileManager
        let
        context = CoreJS.Context.run(
            self.mainScriptURL,
            with: dependencies
            )!

        // Load
        //
        let
        tracker = self.scriptTracker
        context.exceptionHandler = { (context, error) in
            guard let error = error else { return }
            let
            analyticsError = NSError(with: error)
            tracker.receive(analyticsError: analyticsError)
        }
        self.scriptContext = context
        return context
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
        context = self.resolvedScriptContext(),
        manager = context
            .globalObject
            .forProperty("Anna")
            .invokeMethod(
                "default",
                withArguments: []
        )!
        manager.setValue(
            self.scriptTracker,
            forProperty: "tracker"
        )
        self.scriptManager = manager
        return manager
    }

    func
        registerRootNode(
        by locator :NodeLocator
        )
    {
        self.scriptQ.async {
            let
            manager = self.resolvedScriptManager()
            manager.invokeMethod(
                "registerRootNode",
                withArguments: [locator,]
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
            let
            manager = self.resolvedScriptManager()
            manager.invokeMethod(
                "registerNode",
                withArguments: [locator, parentLocator,]
            )
        }
    }
    
    func
        recordEvent(
        with properties :[String: AnyObject],
        locator :NodeLocator
        )
    {
        self.scriptQ.async {
            let
            manager = self.resolvedScriptManager()
            manager.invokeMethod(
                "recordEvent",
                withArguments: [properties, locator,]
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
