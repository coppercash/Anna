
//  ANAManager.swift
//  Anna
//
//  Created by William on 01/07/2017.
//
//

import Foundation
import JavaScriptCore

@objc(ANAFileManaging)
public protocol
    FileManaging
{
    func
        contents(atPath path: String) -> Data?
}

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

public class
    ANAManager :
    NSObject,
    ANAManaging
{
    var
    fileManager :FileManaging! = nil
    public convenience
    init(fileManager: FileManaging) {
        self.init(Proto())
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
            .objectForKeyedSubscript("Anna")
            .invokeMethod(
                "default",
                withArguments: []
        )!
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
