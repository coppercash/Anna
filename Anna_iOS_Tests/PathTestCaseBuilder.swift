//
//  PathTestCaseBuilder.swift
//  Anna_iOS_Tests
//
//  Created by William on 2018/4/14.
//

import Foundation
import UIKit
import XCTest
import Anna

@objc(ANAMockFileManager) class
MockFileManager : NSObject, CoreJS.FileManaging
{
    var
    defaultScript :String? = nil
    func
        contents(atPath path: String) -> Data?
    {
        return self.defaultScript?.data(using: .utf8)
    }
}

@objc(ANAPathTestCaseBuilder) class
PathTestCaseBuilder : NSObject
{
    unowned let
    xcTestCase :XCTestCase
    let
    fileManager = MockFileManager()
    @objc(initWithXCTestCase:)
    init(with xcTestCase :XCTestCase) {
        self.xcTestCase = xcTestCase
        super.init()
    }
    
    var
    defaultScript :String? {
        get {
            return self.fileManager.defaultScript
        }
        set {
            self.fileManager.defaultScript = newValue
        }
    }
    var
    application :UIApplication {
        return UIApplication.shared
    }
    var
    rootViewController :UIViewController? = nil
    func
        launch() {
        let
        delegate = PathTestingAppDelegate()
        delegate.rootViewController = self.rootViewController
        let
        manager = ANAManager(
            mainScriptURL: URL(fileURLWithPath: "main.js"),
            fileManager: self.fileManager
        )
        manager.tracker = self
        delegate.manager = manager
        self.application.delegate = delegate
        let
        _ = delegate.application(
            self.application,
            didFinishLaunchingWithOptions: nil
        )
    }
    
    func
        expect() {
        let
        expectation = self.xcTestCase.expectation(description: "\(self.expectations.count)")
        self.expectations.append(expectation)
    }
    
    var
    expectations = [XCTestExpectation]()
    var
    currentExpectationIndex = 0
    var
    results = [Any]()
    var
    currentResultIndex = 0
    
}
    
extension
PathTestCaseBuilder : Anna.Tracking
{
    func
        receive(
        analyticsResult :AnyObject,
        dispatchedBy manager :Tracking.Manager
        ) {
        DispatchQueue.main.async {
            self.results[self.currentResultIndex] = analyticsResult
            self.currentResultIndex += 1
            self.expectations[self.currentExpectationIndex].fulfill()
            self.currentExpectationIndex += 1
        }
    }
    
    func receive(
        analyticsError :Error,
        dispatchedBy manager :Tracking.Manager
        ) {
    }
}

@objc(ANAPathTestingAppDelegate) class
PathTestingAppDelegate: UIResponder, UIApplicationDelegate, AnalyzerOwner
{
    var
    window: UIWindow?
    var
    rootViewController :UIViewController?
    var
    manager :RootAnalyzer.Manager?
    
    func
        application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
        ) -> Bool
    {
        let
        window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = self.rootViewController ??
            UINavigationController(nibName: nil, bundle: nil)
        window.makeKeyAndVisible()
        self.window = window
        return true
    }
    
    lazy var
    analyzer :Analyzing = {
        RootAnalyzer(manager: self.manager!)
    }()
}

@objc(ANAPathTestingViewController) class
PathTestingViewController : UIViewController, AnalyzerOwner
{
    var
    _analyzer :Analyzing!
    var
    analyzer :Analyzing {
        get { return self._analyzer }
        set { self._analyzer = newValue }
    }
}

@objc(ANAPathTestingButton) class
PathTestingButton : UIButton, AnalyzerOwner
{
    var
    _analyzer :Analyzing!
    var
    analyzer :Analyzing {
        get { return self._analyzer }
        set { self._analyzer = newValue }
    }
}
