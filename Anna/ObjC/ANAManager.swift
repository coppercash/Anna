
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
    ANAManaging
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
    sharedManager: ANAManaging = ANAManager(Proto.shared)
    
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
ANAManager : ANAEventDispatching {
    public func
        dispatchEvent(
        withSeed seed: ANAPayloadCarrying & ANAPointMatchable & ANARegistrantCarrying
        ) {
        proto.queue.async {
            do {
                // Try to load points if they have not been loaded
                //
                try self.loadPoints(for: seed.registrant)
                try self.proto.dispatch(ObjCEventSeed(seed))
            }
            catch {
                self.proto.sendDefaultTrackers(error)
            }
        }
    }
}

extension
ANAClassPointBuilder : ANARegistrationRecording {
}
