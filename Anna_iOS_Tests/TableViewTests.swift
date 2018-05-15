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
        match(
          'tb/sc_0/rw/ui-table-will-display-row',
          function(node) {
            const index = node.indexAmongSiblings;
            if (!(index == 0)) { return undefined; }
            return node.parentNode.nodeName + '_' + index;
          }
        );
        match(
          'tb/sc_3/rw/ui-table-will-display-row',
          function(node) {
            const index = node.indexAmongSiblings;
            if (!(index == 7)) { return undefined; }
            return node.parentNode.nodeName + '_' + index;
          }
        );
        match(
          'tb/sc_0/rw/ana-value-updated',
          function(node) {
            if (!(node.latestValueForKeyPath('identifier') == '0/0')) { return undefined; }
            const last = node.events[node.events.length - 1];
            return last.attributes['value'];
          }
        );
        match(
          'tb/sc_3/rw/ana-value-updated',
          function(node) {
            if (!(node.latestValueForKeyPath('identifier') == '3/7')) { return undefined; }
            const last = node.events[node.events.length - 1];
            return last.attributes['value'];
          }
        );
        """)
        class
            Controller : PathTestingViewController, UITableViewDelegate, UITableViewDataSource, SectionAnalyzableTableViewDelegate
        {
            lazy var
            table :UITableView = {
                let
                superview = self.view!;
                let
                table = PathTestingTableView(frame: superview.bounds)
                table.delegate = self
                table.dataSource = self
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
                        cell.becomeAnalysisObject(named: "rw")
                        cell.analyzer?.observe(
                            owner: cell,
                            for: #keyPath(UITableViewCell.textLabel.text)
                        )
                        return cell
                    }()
                cell.analyzer?.update("\(indexPath.section)/\(indexPath.row)", for: "identifier")
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
                cell.analyzer?.update("\(indexPath.section)\(indexPath.row)", for: "data")
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
        
        test.expect(for: 8)
        test.launch()
        self.wait(
            for: test.expectations,
            timeout: 1.0
        )
        
        XCTAssertEqual(test.results[0] as! String, "0/0")
        XCTAssertEqual(test.results[1] as! String, "sc_0_0")
        XCTAssertEqual(test.results[2] as! String, "0-0")
        XCTAssertEqual(test.results[3] as! String, "00")
        XCTAssertEqual(test.results[4] as! String, "3/7")
        XCTAssertEqual(test.results[5] as! String, "sc_3_7")
        XCTAssertEqual(test.results[6] as! String, "3-7")
        XCTAssertEqual(test.results[7] as! String, "37")
    }
    
    func test_tableViewCellSubviews() {
        let
        test = PathTestCaseBuilder(with: self)
        
        test.task = ("""
        match(
          ['tb/sc_0/rw/ui-table-will-display-row', 'tb/sc_19/rw/ui-table-will-display-row'],
          function(node) { return 'cell-' + node.parentNode.nodeName; }
        );
        match(
          ['tb/sc_0/rw/vw/bt/ui-control-event', 'tb/sc_19/rw/vw/bt/ui-control-event'],
          function(node) { return 'button-' + node.parentNode.parentNode.parentNode.nodeName; }
        );
        match(
          ['tb/sc_0/rw/vw/bt/ana-value-updated', 'tb/sc_19/rw/vw/bt/ana-value-updated'],
          function(node) { return node.latestEvent.attributes['value']; }
        );
        """)
        class
            Controller : PathTestingViewController, UITableViewDelegate, UITableViewDataSource, SectionAnalyzableTableViewDelegate
        {
            lazy var
            table :UITableView = {
                let
                superview = self.view!;
                let
                table = PathTestingTableView(frame: superview.bounds)
                table.delegate = self
                table.dataSource = self
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
                        cell.becomeAnalysisObject(named: "rw")
                        let
                        view = PathTestingView(frame: cell.contentView.bounds)
                        view.becomeAnalysisObject(named: "vw")
                        cell.contentView.addSubview(view)
                        let
                        button = PathTestingButton(type: .custom)
                        button.frame = view.bounds
                        button.becomeAnalysisObject(named: "bt")
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
                button.analyzer?.update("data-\(indexPath.section)", for: "data")
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
            timeout: 999.0
        )
        
        XCTAssertEqual(test.results[0] as! String, "cell-sc_0")
        XCTAssertEqual(test.results[1] as! String, "data-0")
        XCTAssertEqual(test.results[2] as! String, "button-sc_0")
        XCTAssertEqual(test.results[3] as! String, "cell-sc_19")
        XCTAssertEqual(test.results[4] as! String, "data-19")
        XCTAssertEqual(test.results[5] as! String, "button-sc_19")
    }
}
