
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
        if path.hasSuffix("task/index.js") {
            return self.task?.data(using: .utf8)
        }
        else if path.hasSuffix("analytics.bundle/index.js") {
            return ("""
module.exports = require('anna').configured({
  task: (__dirname + '/task')
});
""").data(using: .utf8)
        }
        else {
            return self.fileManager.contents(atPath: path)
        }
    }
    func
        fileExists(
        atPath path: String
        ) -> Bool {
        if path.hasSuffix("task/index.js") {
            return true
        }
        else if path.hasSuffix("index.js") {
            return true
        }
        else {
            return fileManager.fileExists(atPath: path)
        }
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
        bundle = Bundle(for: type(of: self)),
        dep = Dependency()
        dep.exceptionHandler = { (_, e) in print(e!) }
        dep.fileManager = self.fileManager
        dep.logger = Logger()
        dep.coreModuleURL = bundle.url(
            forResource: "anna",
            withExtension: "bundle"
        )
        dep.coreJSModuleURL = bundle.url(
            forResource: "corejs",
            withExtension: "bundle"
        )
        let
        manager = Manager(
            moduleURL: bundle.url(
                forResource: "analytics",
                withExtension: "bundle"
            )!,
            config: [:],
            dependency: dep
        )
        manager.delegate = self
        manager.delegateQueue = DispatchQueue.main
        let
        delegate = PathTestingAppDelegate()
        delegate.rootViewController = self.rootViewController
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
    var
    resultCount :Int { return self.results.count }
    subscript(index :Int) -> Any? {
        return index < self.results.count ? self.results[index] : nil;
    }
}
    
extension
PathTestCaseBuilder : Anna.Delegate
{
    func
        manager(
        _ manager: Manager,
        didSend result: Any
        ) {
        self.results.insert(result, at: self.currentResultIndex)
        self.currentResultIndex += 1
        guard self.currentExpectationIndex < self.expectations.count
            else { return }
        self.expectations[self.currentExpectationIndex].fulfill()
        self.currentExpectationIndex += 1
    }
}

extension
    ProcessInfo
{
    class var
    needDetachAnalyzer :Bool {
        return true
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
    analyzer :Analyzing = {
        RootAnalyzer(manager: self.manager!)
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
    lazy var
    analyzer :Analyzing = { Analyzer.analyzer(with: self) }()
    deinit {
        if ProcessInfo.needDetachAnalyzer {
            self.analyzer.detach()
        }
    }
}

@objc(ANAPathTestingTabBarController) class
    PathTestingTabBarController : UITabBarController, Analyzable
{
    lazy var
    analyzer :Analyzing = { Analyzer.analyzer(with: self) }()
    deinit {
        if ProcessInfo.needDetachAnalyzer {
            self.analyzer.detach()
        }
    }
}

@objc(ANAPathTestingViewController) class
PathTestingViewController : UIViewController, Analyzable
{
    lazy var
    analyzer :Analyzing = { Analyzer.analyzer(with: self) }()
    deinit {
        if ProcessInfo.needDetachAnalyzer {
            self.analyzer.detach()
        }
    }
}

@objc(ANAPathTestingButton) class
PathTestingButton : UIButton, Analyzable
{
    lazy var
    analyzer :Analyzing = { Analyzer.analyzer(with: self) }()
    deinit {
        if ProcessInfo.needDetachAnalyzer {
            self.analyzer.detach()
        }
    }
}

@objc(ANAPathTestingTableView) class
    PathTestingTableView : UITableView, Analyzable
{
    lazy var
    analyzer :Analyzing = { Analyzer.analyzer(with: self) }()
    deinit {
        if ProcessInfo.needDetachAnalyzer {
            self.analyzer.detach()
        }
    }
}

@objc(ANAPathTestingTableViewCell) class
    PathTestingTableViewCell : UITableViewCell, AnalyzerWritable
{
    lazy var
    analyzer :Analyzing = { Analyzer.analyzer(with: self) }()
    deinit {
        if ProcessInfo.needDetachAnalyzer {
            self.analyzer.detach()
        }
    }
}

@objc(ANAPathTestingCollectionView) class
    PathTestingCollectionView : UICollectionView, Analyzable
{
    lazy var
    analyzer :Analyzing = { Analyzer.analyzer(with: self) }()
    deinit {
        if ProcessInfo.needDetachAnalyzer {
            self.analyzer.detach()
        }
    }
}

@objc(ANAPathTestingCollectionViewCell) class
    PathTestingCollectionViewCell : UICollectionViewCell, Analyzable
{
    lazy var
    analyzer :Analyzing = { Analyzer.analyzer(with: self) }()
    deinit {
        if ProcessInfo.needDetachAnalyzer {
            self.analyzer.detach()
        }
    }
}

@objc(ANAPathTestingView) class
    PathTestingView : UIView, Analyzable
{
    lazy var
    analyzer :Analyzing = { Analyzer.analyzer(with: self) }()
    deinit {
        if ProcessInfo.needDetachAnalyzer {
            self.analyzer.detach()
        }
    }
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
    lazy var
    analyzer :Analyzing = { Analyzer.analyzer(with: self) }()
    deinit {
        if ProcessInfo.needDetachAnalyzer {
            self.analyzer.detach()
        }
    }
}
