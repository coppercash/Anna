//
//  PathTestCaseBuilder.swift
//  Anna_iOS_Tests
//
//  Created by William on 2018/4/14.
//

import Foundation
import UIKit
import XCTest
@testable import Anna

@objc(ANAMockFileManager) class
MockFileManager : NSObject, CoreJS.FileManaging
{
    var
    task :String? = nil
    let
    fileManager = FileManager.default
    func
        contents(atPath path: String) -> Data?
    {
        let
        components = path.components(separatedBy: "/")
        if
            components.count >= 2,
            components[components.count - 2] == "task"
        {
            return self.task?.data(using: .utf8)
        }
        return fileManager.contents(atPath: path)
    }
    func
        fileExists(
        atPath path: String
        ) -> Bool {
        return fileManager.fileExists(atPath: path)
    }
}

class
Logger : NSObject, CoreJS.Logging
{
    func
        log(_ string: String) {
        print(string)
    }
}

@objc(ANAPathTestCaseBuilder) class
PathTestCaseBuilder : NSObject
{
    unowned let
    xcTestCase :XCTestCase
    let
    fileManager = MockFileManager()
    lazy var
    dependency :Dependency = {
        let
        dep = Dependency()
        dep.fileManager = self.fileManager
        let
        bundle = Bundle(for: type(of: self)),
        anna = Bundle(path: bundle.path(forResource: "anna_test", ofType: nil)!)!,
        node_modules = Bundle(path: anna.path(forResource: "node_modules", ofType: nil)!)!
        dep.moduleURL = anna.bundleURL
        dep.taskModuleURL = anna.bundleURL.appendingPathComponent("task")
        dep.coreModuleURL = node_modules.url(forResource: "core", withExtension: nil)
        dep.logger = Logger()
        return dep;
    }()
    @objc(initWithXCTestCase:)
    init(with xcTestCase :XCTestCase) {
        self.xcTestCase = xcTestCase
        super.init()
    }
    
    var
    task :String? {
        get {
            return self.fileManager.task
        }
        set {
            self.fileManager.task = newValue
        }
    }
    var
    application :UIApplication {
        return UIApplication.shared
    }
    var
    delegate :UIApplicationDelegate? = nil
    var
    rootViewController :UIViewController? = nil
    func
        launch() {
        let
        delegate = PathTestingAppDelegate()
        delegate.rootViewController = self.rootViewController
        let
        manager = Manager(self.dependency)
        manager.tracker = self
        delegate.manager = manager
        self.application.delegate = delegate
        self.delegate = delegate
        let
        _ = delegate.application(
            self.application,
            didFinishLaunchingWithOptions: nil
        )
    }
    
    func
        expect(for times :Int = 1) {
        for _ in 0..<times {
            let
            expectation = self.xcTestCase.expectation(description: "\(self.expectations.count)")
            self.expectations.append(expectation)
        }
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
        analyticsResult :Any,
        dispatchedBy manager :Manager
        ) {
        DispatchQueue.main.async {
            self.results.insert(analyticsResult, at: self.currentResultIndex)
            self.currentResultIndex += 1
            self.expectations[self.currentExpectationIndex].fulfill()
            self.currentExpectationIndex += 1
        }
    }
    
    func receive(
        analyticsError :Error,
        dispatchedBy manager :Manager
        ) {
        print((analyticsError as NSError).localizedFailureReason!)
        print(analyticsError.localizedDescription)
    }
}

@objc(ANAPathTestingAppDelegate) class
PathTestingAppDelegate: UIResponder, UIApplicationDelegate, Analyzable
{
    var
    window: UIWindow?
    var
    rootViewController :UIViewController?
    var
    manager :Manager?
    lazy var
    analyzer :Analyzing? = {
        RootAnalyzer(manager: self.manager!, name: "root")
    }()
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
}

@objc(ANAPathTestingNavigationController) class
    PathTestingNavigationController : UINavigationController, Analyzable
{
    var
    analyzer :Analyzing?
}

@objc(ANAPathTestingTabBarController) class
    PathTestingTabBarController : UITabBarController, Analyzable
{
    var
    analyzer :Analyzing?
}

@objc(ANAPathTestingViewController) class
PathTestingViewController : UIViewController, Analyzable
{
    var
    analyzer :Analyzing?
}

@objc(ANAPathTestingButton) class
PathTestingButton : UIButton, Analyzable
{
    var
    analyzer :Analyzing?
}

@objc(ANAPathTestingTableView) class
    PathTestingTableView : UITableView, Analyzable
{
    var
    analyzer :Analyzing?
}

@objc(ANAPathTestingTableViewCell) class
    PathTestingTableViewCell : UITableViewCell, AnalyzerWritable
{
    var
    analyzer :Analyzing?
}

@objc(ANAPathTestingView) class
    PathTestingView : UIView, Analyzable
{
    var
    analyzer :Analyzing?
    override func
        setNeedsDisplay() {
        super.setNeedsDisplay()
    }
    override func
        setNeedsLayout() {
        super.setNeedsLayout()
    }
    override func
        didMoveToWindow() {
        super.didMoveToWindow()
    }
    override func
        didMoveToSuperview() {
        super.didMoveToWindow()
    }
}

@objc(ANAPathTestingLabel) class
    PathTestingLabel : UILabel, AnalyzerWritable
{
    var
    analyzer :Analyzing?
}
