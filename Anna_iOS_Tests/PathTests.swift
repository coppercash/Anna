
//  PathTests.swift
//  Anna_iOS_Tests
//
//  Created by William on 2018/4/18.
//

import XCTest
import Anna

class PathTests: XCTestCase {
   
    func test_deregister() {
        let
        test = PathTestCaseBuilder(with: self)
        test.task = ("""
        match(
          'vc/delta/gamma/touch-up-inside',
          function() { return 42; }
        );
        """)
        class
            Controller : PathTestingViewController
        {
            var
            beta :UIView? = nil,
            delta :UIView? = nil,
            gamma :UIButton? = nil
            override func
                viewDidLoad() {
                super.viewDidLoad()
                self.analyzer = Analyzer.analyzer(with: self)

                var
                superview = self.view!
                var
                superAnalyzer = self.analyzer
                for name in ["alpha", "beta", "delta"] {
                    let
                    view = PathTestingView(frame: superview.bounds)
                    view.analyzer = Analyzer.analyzer(with: view)
                    superview.addSubview(view)
                    superAnalyzer.setSubAnalyzer(
                        view.analyzer,
                        for: name
                    )
                    superview = view
                    superAnalyzer = view.analyzer
                    switch name {
                    case "beta":
                        self.beta = view
                    case "delta":
                        self.delta = view
                    default:
                        break
                    }
                }
                let
                button = PathTestingButton(frame: superview.bounds)
                button.analyzer = Analyzer.analyzer(with: button)
                superAnalyzer.setSubAnalyzer(
                    button.analyzer,
                    for: "gamma"
                )
                self.gamma = button
                superview.addSubview(button)
                
                self.analyzer.enable(with: "vc")
            }
            override func
                viewDidAppear(_ animated: Bool) {
                super.viewDidAppear(animated)
                self.gamma?.sendActions(for: .touchUpInside)
                self.beta?.removeFromSuperview()
                self.beta = nil
                self.view?.addSubview(self.delta!)
                // Wait for the autoreleasing pool release beta
                //
                DispatchQueue.main.async {
                    self.gamma?.sendActions(for: .touchUpInside)
                }
            }
        }
        test.rootViewController = Controller()
        
        test.expect()
        test.launch()
        self.wait(
            for: test.expectations,
            timeout: 1.0
        )
        
        XCTAssertEqual(test[0] as? Int, 42)
    }
    
    func test_dataDisplaysOnView() {
        let
        test = PathTestCaseBuilder(with: self)
        test.task =
        """
        const T = require('tool');
        match(
        ['vw/ana-updated', 'vw/ana-appeared'],
        function(n) {
        const text = T.first_displayed(n, 'text');
        return text;
        }
        );
        """
        class
            Controller : PathTestingViewController
        {
            override func
                loadView() {
                self.view = PathTestingView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            }
            var
            label :UILabel? = nil
            override func
                viewDidLoad() {
                super.viewDidLoad()
                self.analyzer.enable(with: "vc")

                let
                superview = self.view as! PathTestingView
                let
                label = UILabel(frame: superview.bounds)
                superview.addSubview(label)
                
                self.analyzer.setSubAnalyzer(
                    superview.analyzer,
                    for: "vw"
                )
                superview.analyzer.observe(label, for: "text")

                self.label = label
            }
            override func
                viewDidAppear(_ animated: Bool) {
                super.viewDidAppear(animated)
                self.label?.text = "42"
                self.label?.text = "43"
            }
        }
        test.rootViewController = Controller()
        
        test.expect(for: 2)
        test.launch()
        self.wait(
            for: test.expectations,
            timeout: 1.0
        )
        
        XCTAssertEqual(test.resultCount, 2)
        XCTAssertEqual(test[0] as? String, "42")
        XCTAssertEqual(test[1] as? String, "43")
    }
    
    func test_dataDisplaysOnViewController() {
        let
        test = PathTestCaseBuilder(with: self)
        test.task =
        """
        const T = require('tool');
        match(
        ['vc/ana-updated', 'vc/ana-appeared'],
        function(n) { return T.first_displayed(n, 'text'); }
        );
        """
        class
            Controller : PathTestingViewController
        {
            var
            label :UILabel? = nil
            override func
                viewDidLoad() {
                super.viewDidLoad()
                self.analyzer.enable(with: "vc")

                let
                superview = self.view!
                let
                label = PathTestingLabel(frame: superview.bounds)
                superview.addSubview(label)
                self.label = label
                
                self.analyzer.observe(label, for: "text")
            }
            override func
                viewDidAppear(_ animated: Bool) {
                super.viewDidAppear(animated)
                self.label?.text = "42"
            }
            deinit {
                self.analyzer.detach()
            }
        }
        test.rootViewController = Controller()
        
        test.expect()
        test.launch()
        self.wait(
            for: test.expectations,
            timeout: 1.0
        )
        
        XCTAssertEqual(test[0] as? String, "42")
    }
    
    func test_navigatedControllers() {
        let
        test = PathTestCaseBuilder(with: self)
        test.task =
        """
        match(
        '/nv/ms/dt/ana-appeared',
        function() { return 42; }
        );
        """
        class
            Navigation : PathTestingNavigationController
        {
            override func
                viewDidLoad() {
                self.analyzer.enable(with: "nv")
            }
            override func
                viewDidAppear(_ animated: Bool) {
                super.viewDidAppear(animated)
                let
                master = PathTestingViewController()
                master.analyzer.enable(with: "ms")
                self.pushViewController(master, animated: false)
                let
                detail = PathTestingViewController()
                detail.analyzer.enable(with: "dt")
                self.pushViewController(detail, animated: false)
            }
        }
        test.rootViewController = Navigation()
        
        test.expect()
        test.launch()
        self.wait(
            for: test.expectations,
            timeout: 1.0
        )
        
        XCTAssertEqual(test[0] as? Int, 42)
    }
    
    func test_tabController() {
        let
        test = PathTestCaseBuilder(with: self)
        test.task =
        """
        match(
        '/tb/one/ana-appeared',
        function() { return 42; }
        );
        match(
        '/tb/two/ana-appeared',
        function() { return 43; }
        );
        """
        class
            TabBar : PathTestingTabBarController
        {
            override func
                viewDidLoad() {
                let
                controllers = ["one", "two"].map { (name :String) -> PathTestingViewController in
                    let
                    controller = PathTestingViewController()
                    self.analyzer.setSubAnalyzer(controller.analyzer, for: name)
                    return controller
                }
                self.viewControllers = controllers
                self.analyzer.enable(with: "tb")
            }
            override func
                viewDidAppear(_ animated: Bool) {
                super.viewDidAppear(animated)
                self.selectedIndex = 1
            }
        }
        test.rootViewController = TabBar()
        
        test.expect(for: 2)
        test.launch()
        self.wait(
            for: test.expectations,
            timeout: 1.0
        )
        
        XCTAssertEqual(test[0] as? Int, 42)
        XCTAssertEqual(test[1] as? Int, 43)
    }
    
    func test_customRootTabBarController() {
        let
        test = PathTestCaseBuilder(with: self)
        test.task =
        """
        match(
        '/nv/home/two/detail/ana-appeared',
        function() { return 42; }
        );
        """
        class
            Home : PathTestingTabBarController
        {
            override func
                viewDidLoad() {
                let
                controllers = ["one", "two"].map { (name :String) -> PathTestingViewController in
                    let
                    controller = PathTestingViewController()
                    self.analyzer.setSubAnalyzer(
                        controller.analyzer,
                        for: name
                    )
                    return controller
                }
                self.viewControllers = controllers
                self.analyzer.enable(with: "home")
            }
            override func
                viewDidAppear(_ animated: Bool) {
                super.viewDidAppear(animated)
                self.selectedIndex = 1
                let
                detail = PathTestingViewController()
                detail.analyzer.enable(with: "detail")
                self.navigationController?.pushViewController(
                    detail,
                    animated: false
                )
            }
            override func
                redirectedConstitutor(
                for another: FocusPathConstituting,
                isOwning: UnsafeMutablePointer<Bool>
                ) -> FocusPathConstituting? {
                if let
                    controller = another as? UIViewController,
                    let
                    controllers = self.viewControllers
                {
                    if (controllers.contains(controller)) {
                        return self
                    }
                    else {
                        return self.selectedViewController;
                    }
                }
                else {
                    return super.redirectedConstitutor(
                        for: another,
                        isOwning: isOwning
                    )
                }
            }
        }
        class
            Navigation : PathTestingNavigationController
        {
            override func
                viewDidLoad() {
                super.viewDidLoad()
                self.analyzer.enable(with: "nv")
            }
        }
        test.rootViewController = Navigation(rootViewController: Home())

        test.expect()
        test.launch()
        self.wait(
            for: test.expectations,
            timeout: 1.0
        )
        
        XCTAssertEqual(test[0] as? Int, 42)
    }
}
