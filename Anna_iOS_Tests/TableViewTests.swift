//
//  TableViewTests.swift
//  Anna_iOS_Tests
//
//  Created by William on 2018/5/9.
//

import XCTest
import Anna

class TableViewTests: XCTestCase {
    
    func test_tableView() {
        let
        test = PathTestCaseBuilder(with: self)
        
        test.task = ("""
        var T = require('tool');
        match(
          ['tb/sc_0/rw/ana-appeared', 'tb/sc_3/rw/ana-appeared'],
          function(n) {
            var id = n.latestValue('identifier');
            if (!((id === '0/0') || (id === '3/7'))) { return undefined; }
            if (!(
                T.first_displayed(n, 'identifier')
            )) { return undefined; }
            return id + '_appeared';
          }
        );
        match(
          ['tb/sc_0/rw/ana-updated', 'tb/sc_3/rw/ana-updated'],
          function(n) {
            var id = n.latestValue('identifier');
            if (!((id === '0/0') || (id === '3/7'))) { return undefined; }
            var e = n.latestEvent(), keyPath = e.attributes['key-path'];
            if (!(keyPath != 'identifier')) { return; }
            return keyPath + '_' + e.attributes.value;
          }
        );
        """)
        class
            Controller : PathTestingViewController, UITableViewDelegate, UITableViewDataSource, SectionAnalyzableTableViewDelegate
        {
            lazy var
            table :PathTestingTableView = {
                let
                superview = self.view!;
                let
                table = PathTestingTableView(frame: superview.bounds)
                table.delegate = self
                table.dataSource = self
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
                self.table.scrollToRow(
                    at: IndexPath(row: 7, section: 3),
                    at: .bottom,
                    animated: false
                )
            }
            func
                tableView(
                _ tableView: UITableView,
                cellForRowAt indexPath: IndexPath
                ) -> UITableViewCell {
                let
                cell = (tableView.dequeueReusableCell(withIdentifier: "r") as? PathTestingTableViewCell) ??
                    {
                        let
                        cell = PathTestingTableViewCell(
                            style: .default,
                            reuseIdentifier: "r"
                        )
                        cell.analyzer.enable(naming: "rw")
                        cell.analyzer.observe(
                            cell,
                            for: #keyPath(UITableViewCell.textLabel.text)
                        )
                        return cell
                    }()
                cell.analyzer.update(
                    "\(indexPath.section)/\(indexPath.row)",
                    for: "identifier"
                )
                return cell
            }
            func
                tableView(
                _ tableView: UITableView,
                willDisplay cell: UITableViewCell,
                forRowAt indexPath: IndexPath
                ) {
                let
                cell = cell as! PathTestingTableViewCell
                cell.textLabel?.text = "\(indexPath.section)-\(indexPath.row)"
                cell.analyzer.update(
                    "\(indexPath.section)\(indexPath.row)",
                    for: "data"
                )
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
                _ tableView: UITableView & AnalyzerReadable,
                analyticNameFor section :Int
                ) -> String? {
                return "sc_\(section)"
            }
        }
        test.rootViewController = Controller()
        
        test.expect(for: 6)
        test.launch()
        self.wait(
            for: test.expectations,
            timeout: 1.0
        )
        
        XCTAssertEqual(test[0] as? String, "0/0_appeared")
        XCTAssertEqual(test[1] as? String, "textLabel.text_0-0")
        XCTAssertEqual(test[2] as? String, "data_00")
        XCTAssertEqual(test[3] as? String, "3/7_appeared")
        XCTAssertEqual(test[4] as? String, "textLabel.text_3-7")
        XCTAssertEqual(test[5] as? String, "data_37")
    }
    
    func test_tableViewCellSubviews() {
        let
        test = PathTestCaseBuilder(with: self)
        
        test.task = ("""
        var T = require('tool');
        match(
          ['tb/sc_0/rw/ana-appeared', 'tb/sc_19/rw/ana-appeared'],
          function(node) {
            if (!(T.first_displayed(node))) { return undefined; }
            return 'cell-' + node.parentNode.nodeName;
          }
        );
        match(
          ['tb/sc_0/rw/vw/bt/touch-up-inside', 'tb/sc_19/rw/vw/bt/touch-up-inside'],
          function(node) { return 'button-' + node.parentNode.parentNode.parentNode.nodeName; }
        );
        match(
          ['tb/sc_0/rw/vw/bt/ana-updated', 'tb/sc_19/rw/vw/bt/ana-updated'],
          function(node) { return node.latestEvent().attributes['value']; }
        );
        """)
        class
            Controller : PathTestingViewController, UITableViewDelegate, UITableViewDataSource, SectionAnalyzableTableViewDelegate
        {
            lazy var
            table :PathTestingTableView = {
                let
                superview = self.view!
                let
                table = PathTestingTableView(frame: superview.bounds)
                table.delegate = self
                table.dataSource = self
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
                self.table.scrollToRow(
                    at: IndexPath(row: 0, section: 19),
                    at: .bottom,
                    animated: false
                )
            }
            func
                tableView(
                _ tableView: UITableView,
                cellForRowAt indexPath: IndexPath
                ) -> UITableViewCell {
                let
                cell = (tableView.dequeueReusableCell(withIdentifier: "r") as? PathTestingTableViewCell) ??
                    {
                        let
                        cell = PathTestingTableViewCell(
                            style: .default,
                            reuseIdentifier: "r"
                        )
                        cell.analyzer.enable(naming: "rw")
                        let
                        view = PathTestingView(frame: cell.contentView.bounds)
                        cell.analyzer.setSubAnalyzer(
                            view.analyzer,
                            for: "vw"
                        )
                        cell.contentView.addSubview(view)
                        let
                        button = PathTestingButton(type: .custom)
                        button.frame = view.bounds
                        view.analyzer.setSubAnalyzer(
                            button.analyzer,
                            for: "bt"
                        )
                        view.addSubview(button)
                        return cell
                    }()
                return cell
            }
            func
                tableView(
                _ tableView: UITableView,
                willDisplay cell: UITableViewCell,
                forRowAt indexPath: IndexPath
                ) {
                let
                button = cell.contentView.subviews[0].subviews[0] as! PathTestingButton
                button.analyzer.update(
                    "data-\(indexPath.section)",
                    for: "data"
                )
                button.sendActions(for: .touchUpInside)
            }
            func
                tableView(
                _ tableView: UITableView,
                numberOfRowsInSection section: Int
                ) -> Int {
                return 1
            }
            func
                numberOfSections(
                in tableView: UITableView
                ) -> Int {
                return 20
            }
            func
                tableView(
                _ tableView: UITableView & AnalyzerReadable,
                analyticNameFor section :Int
                ) -> String? {
                return "sc_\(section)"
            }
        }
        test.rootViewController = Controller()
        
        test.expect(for: 6)
        test.launch()
        self.wait(
            for: test.expectations,
            timeout: 1.0
        )
        
        XCTAssertEqual(test[0] as? String, "cell-sc_0")
        XCTAssertEqual(test[1] as? String, "data-0")
        XCTAssertEqual(test[2] as? String, "button-sc_0")
        XCTAssertEqual(test[3] as? String, "cell-sc_19")
        XCTAssertEqual(test[4] as? String, "data-19")
        XCTAssertEqual(test[5] as? String, "button-sc_19")
    }
    
    func test_tableViewSectionShouldReportAppeared() {
        let
        test = PathTestCaseBuilder(with: self)
        
        test.task = ("""
        match(
          'tb/sc_0/ana-appeared',
          function(node) { return 42; }
        );
        match(
          'tb/sc_19/ana-appeared',
          function(node) { return 43; }
        );
        """)
        class
            Controller : UIViewController, UITableViewDelegate, UITableViewDataSource, SectionAnalyzableTableViewDelegate
        {
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
                self.view.addSubview(self.table)
                self.table.analyzer.enable(naming: "tb")
            }
            override func
                viewDidAppear(_ animated: Bool) {
                super.viewDidAppear(animated)
                self.table.scrollToRow(
                    at: IndexPath(row: 0, section: 19),
                    at: .bottom,
                    animated: false
                )
            }
            func
                tableView(
                _ tableView: UITableView,
                cellForRowAt indexPath: IndexPath
                ) -> UITableViewCell {
                return table.dequeueReusableCell(
                    withIdentifier: "r",
                    for: indexPath
                )
            }
            func
                tableView(
                _ tableView: UITableView,
                numberOfRowsInSection section: Int
                ) -> Int {
                return 1
            }
            func
                numberOfSections(
                in tableView: UITableView
                ) -> Int {
                return 20
            }
            func
                tableView(
                _ tableView: UITableView & AnalyzerReadable,
                analyticNameFor section :Int
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
        
        XCTAssertEqual(test.resultCount, 2)
        XCTAssertEqual(test[0] as? Int, 42)
        XCTAssertEqual(test[1] as? Int, 43)
    }
}
