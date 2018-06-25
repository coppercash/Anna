//
//  ReuseTests.swift
//  Anna_iOS_Tests
//
//  Created by William on 2018/6/2.
//

import XCTest

class ReuseTests: XCTestCase {
    
    func test_sub_analyzer_of_a_reused_analyzer_should_inherit_the_events_happend_on_analyzer_with_same_key_path() {
        let
        test = PathTestCaseBuilder(with: self)
        test.task = ("""
        match(
          'tb/rw/vw/ana-updated',
          function(node) {
            if (!(node.ancestor(1).index == 0)) { return undefined; }
            var
            first = node.latestValue('count_10'),
            second = node.latestValue('count_11');
            return first + (second ? second : 0);
          }
        );
        """)
        class
            Controller : PathTestingViewController, UITableViewDelegate, UITableViewDataSource
        {
            var
            counter = 10
            lazy var
            table :PathTestingTableView = {
                let
                superview = self.view!;
                let
                table = PathTestingTableView(frame: superview.bounds)
                table.delegate = self
                table.dataSource = self
                table.register(
                    PathTestingTableViewCell.self,
                    forCellReuseIdentifier: "r"
                )
                return table
            }()
            override func
                viewDidLoad() {
                super.viewDidLoad()
                self.analyzer.enable(naming: "vc")
                self.view.addSubview(self.table)
                self.analyzer.setSubAnalyzer(
                    self.table.analyzer,
                    for: "tb"
                )
            }
            override func
                viewDidAppear(_ animated: Bool) {
                super.viewDidAppear(animated)
                DispatchQueue.main.async {
                    self.table.scrollToRow(
                        at: IndexPath(row: 9, section: 1),
                        at: .middle, animated: false
                    )
                    DispatchQueue.main.async {
                        self.table.scrollToRow(
                            at: IndexPath(row: 0, section: 0),
                            at: .middle, animated: false
                        )
                    }
                }
            }
            func
                tableView(
                _ tableView: UITableView,
                cellForRowAt indexPath: IndexPath
                ) -> UITableViewCell {
                let
                cell = tableView.dequeueReusableCell(
                    withIdentifier: "r",
                    for: indexPath
                ) as! PathTestingTableViewCell
                cell.analyzer.enable(naming: "rw")
                let
                subview = PathTestingView(frame: cell.contentView.bounds)
                cell.contentView.addSubview(subview)
                cell.analyzer.setSubAnalyzer(
                    subview.analyzer,
                    for: "vw"
                )
                if indexPath.section == 0 && indexPath.row == 0 {
                    subview.analyzer.update(
                        self.counter,
                        for: "count_\(self.counter)"
                    )
                    self.counter += 1
                }
                return cell
            }
            func
                tableView(
                _ tableView: UITableView,
                numberOfRowsInSection section: Int
                ) -> Int {
                return 10
            }
            func
                numberOfSections(
                in tableView: UITableView
                ) -> Int {
                return 2
            }
        }
        test.rootViewController = Controller()
        
        test.expect(for: 2)
        test.launch()
        self.wait(
            for: test.expectations,
            timeout: 1.0
        )
        
        XCTAssertEqual(test[0] as? Int, 10)
        XCTAssertEqual(test[1] as? Int, 21)
    }
    
    // This test case doesn't really test the function.
    // It just constructs a case to view the log,
    // so it is confirmed that the functoin works properly.
    //
    func
        test_unowned_sub_analyzer_should_be_deregister_properly() {
        let
        test = PathTestCaseBuilder(with: self)
        test.task = ("""
        match(
          'tb/rw/vc/ana-disappeared',
          function(node) { return 42; }
        );
        """)
        class
            Controller : PathTestingViewController, UITableViewDelegate, UITableViewDataSource
        {
            var
            counter = 10
            lazy var
            table :PathTestingTableView = {
                let
                superview = self.view!;
                let
                table = PathTestingTableView(frame: superview.bounds)
                table.delegate = self
                table.dataSource = self
                table.register(
                    PathTestingTableViewCell.self,
                    forCellReuseIdentifier: "r"
                )
                return table
            }()
            override func
                viewDidLoad() {
                super.viewDidLoad()
                self.analyzer.enable(naming: "vc")
                self.view.addSubview(self.table)
                self.analyzer.setSubAnalyzer(
                    self.table.analyzer,
                    for: "tb"
                )
            }
            override func
                viewDidAppear(_ animated: Bool) {
                super.viewDidAppear(animated)
                self.table.delegate?.tableView?(
                    self.table,
                    didSelectRowAt: IndexPath(row: 0, section: 0)
                )
            }
            func
                tableView(
                _ tableView: UITableView,
                cellForRowAt indexPath: IndexPath
                ) -> UITableViewCell {
                let
                cell = tableView.dequeueReusableCell(
                    withIdentifier: "r",
                    for: indexPath
                ) as! PathTestingTableViewCell
                cell.analyzer.enable(naming: "rw")
                return cell
            }
            func
                tableView(
                _ tableView: UITableView,
                numberOfRowsInSection section: Int
                ) -> Int {
                return 20
            }
            func
                tableView(
                _ tableView: UITableView,
                didSelectRowAt indexPath: IndexPath
                ) {
                let
                controller = PathTestingViewController()
                controller.analyzer.enable(naming: "vc")
                self.navigationController?.pushViewController(
                    controller,
                    animated: false
                )
                DispatchQueue.main.async {
                    tableView.scrollToRow(
                        at: IndexPath(row: 19, section: 0),
                        at: .bottom,
                        animated: false
                    )
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(
                            animated: false
                        )
                    }
                }
            }
        }
        test.rootViewController = UINavigationController(
            rootViewController: Controller()
        )

        test.expect()
        test.launch()
        self.wait(
            for: test.expectations,
            timeout: 1.0
        )
        
        XCTAssertEqual(test[0] as? Int, 42)
    }
    
    func
        test_reload_data() {
        let
        test = PathTestCaseBuilder(with: self)
        test.task = ("""
        match(
          'tb/rw/ana-updated',
          function(node) {
            if (!(node.latestValue('trigger') == 7)) { return undefined; }
            return node.latestValue('answer') === undefined ? 42 : undefined;
          }
        );
        """)
        class
            Controller : PathTestingViewController, UITableViewDelegate, UITableViewDataSource
        {
            var
            counter = 10
            lazy var
            table :PathTestingTableView = {
                let
                superview = self.view!;
                let
                table = PathTestingTableView(frame: superview.bounds)
                table.delegate = self
                table.dataSource = self
                table.register(
                    PathTestingTableViewCell.self,
                    forCellReuseIdentifier: "r"
                )
                return table
            }()
            override func
                viewDidLoad() {
                super.viewDidLoad()
                self.analyzer.enable(naming: "vc")
                self.view.addSubview(self.table)
                self.analyzer.setSubAnalyzer(
                    self.table.analyzer,
                    for: "tb"
                )
            }
            override func
                viewDidAppear(_ animated: Bool) {
                super.viewDidAppear(animated)
                let
                cell = self.table.cellForRow(at: IndexPath(row: 0, section: 0)) as! PathTestingTableViewCell
                cell.analyzer.update(7, for: "answer")
                DispatchQueue.main.async {
                    self.table.reloadData()
                    DispatchQueue.main.async {
                        let
                        cell = self.table.cellForRow(at: IndexPath(row: 0, section: 0)) as! PathTestingTableViewCell
                        cell.analyzer.update(7, for: "trigger")
                    }
                }
            }
            func
                tableView(
                _ tableView: UITableView,
                cellForRowAt indexPath: IndexPath
                ) -> UITableViewCell {
                let
                cell = tableView.dequeueReusableCell(
                    withIdentifier: "r",
                    for: indexPath
                    ) as! PathTestingTableViewCell
                cell.analyzer.enable(naming: "rw")
                return cell
            }
            func
                tableView(
                _ tableView: UITableView,
                numberOfRowsInSection section: Int
                ) -> Int {
                return 20
            }
        }
        test.rootViewController = Controller()
        
        test.expect()
        test.launch()
        self.wait(
            for: test.expectations,
            timeout: 999.0
        )
        
        XCTAssertEqual(test[0] as? Int, 42)
    }
}
