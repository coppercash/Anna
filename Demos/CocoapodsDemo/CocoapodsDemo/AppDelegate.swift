//
//  AppDelegate.swift
//  CocoapodsDemo
//
//  Created by William on 28/07/2017.
//  Copyright © 2017 coppercash. All rights reserved.
//

import UIKit
import Anna

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, Analyzable {

    var window: UIWindow?
    lazy var tracker :Tracker = Tracker()
    lazy var manager :Manager = {
        let dependency = Dependency()
        let
        moduleURL = Bundle.main.url(
            forResource: "analytics",
            withExtension: "bundle"
            )!
        dependency.moduleURL = moduleURL
        dependency.taskModuleURL = moduleURL.appendingPathComponent("task")
        dependency.config = ["debug" as NSString : true as NSNumber]
        dependency.logger = self.tracker
        let
        manager = Manager(dependency)
        manager.tracker = self.tracker
        return manager
    }()
    lazy var analyzer :Analyzing? = {
        return RootAnalyzer(
            manager: self.manager,
            name: "root"
        )
    }()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
        ) -> Bool {
        return true
    }
}
