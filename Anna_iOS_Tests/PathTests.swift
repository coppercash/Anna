
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
                
                self.analyzer = Analyzer.hooking(delegate: self, naming: "vc")
                
                self.button = {
                    let
                    button = PathTestingButton()
                    button.analyzer = Analyzer.hooking(delegate: button, naming: "bt")
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
        function() { return '0_0'; }
        );
        match(
        'vc/tb/sc_3/rw_7/ui-table-will-display-row',
        function() { return '3_7'; }
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
                table.analyzer = {
                    let
                    ana = Analyzer.hooking(delegate: table, naming: "tb")
                    return ana
                }()
                return table
            }()
            override func
                viewDidLoad() {
                super.viewDidLoad()
                self.analyzer = {
                    let
                    ana = Analyzer.hooking(delegate: self, naming: "vc")
                    ana.hook(self)
                    return ana
                }()
                
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
                self.analyzer = Analyzer.hooking(delegate: self, naming: "vc")
                
                var
                superview = self.view!
                for name in ["alpha", "beta", "delta"] {
                    let
                    view = PathTestingView(frame: superview.bounds)
                    view.analyzer = Analyzer.hooking(delegate: view, naming: name)
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
                button.analyzer = Analyzer.hooking(delegate: button, naming: "gamma")
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
            timeout: 999999.0
        )
        
        XCTAssertEqual(test.results[0] as! Int, 42)
    }
    
    func test_dataExposuredOnView() {
        let
        test = PathTestCaseBuilder(with: self)
        test.task =
        """
        match(
        'vw/ana-appeared',
        function(node) { console.log(node.snapshot()); }
        );
        """
            /*
        """
        const Q = require('../reader');
        match(
        'vw/ana-value-updated',
        Q.whenViewVisible('text', '42', function(node) { return node.name; })
        );
        """
 */
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
                
                let
                analyzer = Analyzer.hooking(delegate: superview, naming: "vw")
                analyzer.observe(label, for: "text")
                superview.analyzer = analyzer
                
                self.label = label
            }
            override func
                viewDidAppear(_ animated: Bool) {
                super.viewDidAppear(animated)
                self.label?.text = "42"
                self.view?.isHidden = true
            }
        }
        test.rootViewController = Controller()
        
        test.expect()
        test.launch()
        self.wait(
            for: test.expectations,
            timeout: 9999999.0
        )
        
        XCTAssertEqual(test.results[0] as! String, "42")
    }
}
