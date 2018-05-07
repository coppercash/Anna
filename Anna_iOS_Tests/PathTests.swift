
//  PathTests.swift
//  Anna_iOS_Tests
//
//  Created by William on 2018/4/18.
//

import XCTest
import Anna

class PathTests: XCTestCase {
   
    func test_button() {
        let
        test = PathTestCaseBuilder(with: self)
        test.task =
        """
        match(
        'vc/bt/ui-control-event',
        function() { return 42; }
        );
        """
        class
        Controller : PathTestingViewController
        {
            var
            button :UIButton? = nil
            override func
                viewDidLoad() {
                super.viewDidLoad()
                self.becomeAnalysisObject(named: "vc")
                
                self.button = {
                    let
                    button = PathTestingButton()
                    button.becomeAnalysisObject(named: "bt")
                    return button
                }()
                self.view.addSubview(self.button!)
            }
            override func
                viewDidAppear(_ animated: Bool) {
                super.viewDidAppear(animated)
                self.button?.sendActions(for: .touchUpInside)
            }
        }
        test.rootViewController = Controller()

        test.expect()
        test.launch()
        self.wait(
            for: test.expectations,
            timeout: 1.0
        )
        
        XCTAssertEqual(test.results[0] as! Int, 42)
    }

    func test_tableView() {
        let
        test = PathTestCaseBuilder(with: self)
        test.task =
        """
        match(
        'vc/tb/sc_0/rw_0/ui-table-will-display-row',
        function(node) { return '0_0'; }
        );
        match(
        'vc/tb/sc_3/rw_7/ui-table-will-display-row',
        function(node) { return '3_7'; }
        );
        """
        class
            Controller : PathTestingViewController, UITableViewDelegate, UITableViewDataSource, AnalyzableTableViewDelegate
        {
            lazy var
            table :UITableView = {
                let
                superview = self.view!;
                let
                table = PathTestingTableView(frame: superview.bounds)
                table.delegate = self
                table.dataSource = self
                table.register(PathTestingTableViewCell.self, forCellReuseIdentifier: "r")
                table.becomeAnalysisObject(named: "tb")
                return table
            }()
            override func
                viewDidLoad() {
                super.viewDidLoad()
                self.becomeAnalysisObject(named: "vc")
                self.view.addSubview(self.table)
                
            }
            override func
                viewDidAppear(_ animated: Bool) {
                super.viewDidAppear(animated)
                self.table.scrollToRow(
                    at: IndexPath(row: 7, section: 3),
                    at: .bottom,
                    animated: false
                )
            }
            @objc func
                tableView(
                _ tableView: UITableView,
                cellForRowAt indexPath: IndexPath
                ) -> UITableViewCell {
                return tableView.dequeueReusableCell(withIdentifier: "r", for: indexPath)
            }
            func
                tableView(
                _ tableView: UITableView,
                numberOfRowsInSection section: Int
                ) -> Int {
               return 8
            }
            func
                numberOfSections(
                in tableView: UITableView
                ) -> Int {
                return 4
            }
            func
                tableView(
                _ tableView: UITableView,
                analyzerNameForRowAt indexPath: IndexPath
                ) -> String? {
                return "rw_\(indexPath.row)"
            }
            func
                tableView(
                _ tableView: UITableView,
                analyzerNameFor section: Int
                ) -> String? {
                return "sc_\(section)"
            }
        }
        test.rootViewController = Controller()
        
        test.expect(for: 2)
        test.launch()
        self.wait(
            for: test.expectations,
            timeout: 1.0
        )
        
        XCTAssertEqual(test.results[0] as! String, "0_0")
        XCTAssertEqual(test.results[1] as! String, "3_7")
    }
    
    func test_deregister() {
        let
        test = PathTestCaseBuilder(with: self)
        test.task =
        """
        match(
        'vc/delta/gamma/ui-control-event',
        function() { return 42; }
        );
        """
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
                self.becomeAnalysisObject(named: "vc")

                var
                superview = self.view!
                for name in ["alpha", "beta", "delta"] {
                    let
                    view = PathTestingView(frame: superview.bounds)
                    view.becomeAnalysisObject(named: name)
                    superview.addSubview(view)
                    superview = view
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
                button.becomeAnalysisObject(named: "gamma")
                self.gamma = button
                superview.addSubview(button)
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
        
        XCTAssertEqual(test.results[0] as! Int, 42)
    }
    
    func test_dataDisplaysOnView() {
        let
        test = PathTestCaseBuilder(with: self)
        test.task =
        """
        const T = require('../tool');
        match(
        ['vw/ana-value-updated', 'vw/ana-appeared'],
        T.whenDisplays('text', function(node, value) { return value; })
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
                
                let
                superview = self.view as! PathTestingView
                let
                label = UILabel(frame: superview.bounds)
                superview.addSubview(label)
                
                superview.becomeAnalysisObject(named: "vw")
                superview.analyzer?.observe(label, for: "text")

                self.label = label
            }
            override func
                viewDidAppear(_ animated: Bool) {
                super.viewDidAppear(animated)
                self.label?.text = "42"
            }
        }
        test.rootViewController = Controller()
        
        test.expect()
        test.launch()
        self.wait(
            for: test.expectations,
            timeout: 1.0
        )
        
        XCTAssertEqual(test.results[0] as! String, "42")
    }
    
    func test_dataDisplaysOnViewController() {
        let
        test = PathTestCaseBuilder(with: self)
        test.task =
        """
        const T = require('../tool');
        match(
        ['vc/ana-value-updated', 'vc/ana-appeared'],
        T.whenDisplays('text', function(node, value) { return value; })
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
                self.becomeAnalysisObject(named: "vc")

                let
                superview = self.view!
                let
                label = UILabel(frame: superview.bounds)
                superview.addSubview(label)
                self.label = label
                
                self.analyzer?.observe(label, for: "text")
            }
            override func
                viewDidAppear(_ animated: Bool) {
                super.viewDidAppear(animated)
                self.label?.text = "42"
            }
        }
        test.rootViewController = Controller()
        
        test.expect()
        test.launch()
        self.wait(
            for: test.expectations,
            timeout: 1.0
        )
        
        XCTAssertEqual(test.results[0] as! String, "42")
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
                self.becomeAnalysisObject(named: "nv")
            }
            override func
                viewDidAppear(_ animated: Bool) {
                super.viewDidAppear(animated)
                let
                master = PathTestingViewController()
                master.becomeAnalysisObject(named: "ms")
                self.pushViewController(master, animated: false)
                let
                detail = PathTestingViewController()
                detail.becomeAnalysisObject(named: "dt")
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
        
        XCTAssertEqual(test.results[0] as! Int, 42)
    }
}
