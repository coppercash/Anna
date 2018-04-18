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
MockFileManager : NSObject, Anna.FileManaging
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
    let
    manager :ANAManager
    @objc(initWithXCTestCase:)
    init(with xcTestCase :XCTestCase) {
        self.xcTestCase = xcTestCase
        self.manager = ANAManager(
            fileManager: self.fileManager
        )
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
PathTestCaseBuilder : Anna.ANATracking
{
    func receiveAnalyticsError(
        _ error: Error,
        dispatchedBy manager: ANAManaging
        ) {
    }
    
    func receiveAnalyticsResult(
        _ result: Any,
        dispatchedBy manager: ANAManaging
        ) {
        DispatchQueue.main.async {
            self.results[self.currentResultIndex] = result
            self.currentResultIndex += 1
            self.expectations[self.currentExpectationIndex].fulfill()
            self.currentExpectationIndex += 1
        }
    }
    
    // TODO: Remove
    func receiveAnalyticsEvent(
        _ event: ANAEventBeing,
        dispatchedBy manager: ANAManaging
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
        RootAnalyzer(manager: RootAnalyzer.Manager.sharedManager)
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
