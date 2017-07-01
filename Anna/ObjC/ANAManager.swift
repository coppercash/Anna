//
//  ANAManager.swift
//  Anna
//
//  Created by William on 01/07/2017.
//
//

import Foundation

public class
    ANAManager :
    NSObject,
    ANAManagerProtocol
{
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
    trackers :ANATrackerCollection & ANATrackerConfigurator
    public static var
    shared: ANAManagerProtocol = ANAManager(Proto.shared)
    
    // MARK: - Load
    
    typealias
        Registrant = ANARegistering.Type
    typealias
        ClassPoint = ANAClassPoint
    typealias
        ClassPointBuilder = ANAClassPointBuilder
    func loadPoints(for registrant :Registrant) throws {
        guard
            (proto.root.classPoint(for: registrant) is ClassPoint) == false
            else { return }
        let
        builder = ClassPointBuilder(ClassPointBuilder.Proto(trackers: proto.trackers))
        registrant.ana_registerAnalyticsPoints(withRegistrar: builder)
        let
        point = try builder.build()
        point.parent = proto.root
        
        proto.root.setClassPoint(point, for: registrant)
    }
}

extension
ANAManager : ANAEventDispatchingProtocol {
    public func
        dispatchEvent(
        withSeed seed: ANAPayloadCarryingProtocol & ANAPointMatchableProtocol
        ) {
        proto.queue.async {
            do {
                // Try to load points if they have not been loaded
                //
                try self.loadPoints(for: seed.cls as! Registrant)
                try self.proto.dispatch(ObjCEventSeed(seed))
            }
            catch {
                self.proto.sendDefaultTrackers(error)
            }
        }
    }
}

//extension
//NSObject : EasyAnalyzable {
//    public static func
//        registerAnalyticsPoints(with registrar: EasyRegistrant.Registrar) {
//        guard let registering = self as? ANARegistering else { return }
//        let objCRegistrar = ANAClassPointBuilder(registrar as! EasyClassPointBuilder)
//        registering.ana_registerAnalyticsPoints(withRegistrar: objCRegistrar)
//    }
//}

extension
ANAClassPointBuilder : ANARegistrationRecording {
}
