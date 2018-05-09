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
          ['tb/sc_0/rw/ana-value-updated', 'tb/sc_3/rw/ana-value-updated'],
          function(node) {
            const last = node.events[node.events.length - 1];
            const keyPath = last.attributes['key-path'];
            const value = last.attributes['value'];
            switch (keyPath) {
            case 'textLabel.text':
              switch(value) {
              case '0/0':
              case '3/7':
            console.log(node.snapshot());
                return value;
              default:
                return undefined;
              }
            case 'foo':
              switch(value) {
              case '0-0':
              case '3-7':
                return value;
              default:
                return undefined;
              }
            default:
              return undefined;
            }
          }
        );
        """)
        class
            Controller : PathTestingViewController, UITableViewDelegate, UITableViewDataSource, AnalyzableGroupedTableViewDelegate
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
                guard let
                    cell = tableView.dequeueReusableCell(withIdentifier: "r") as? PathTestingTableViewCell
                else {
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
                }
                print(indexPath)
                cell.textLabel?.text = "\(indexPath.section)/\(indexPath.row)"
                cell.analyzer?.update("\(indexPath.section)-\(indexPath.row)", for: "foo")
                return cell
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
                analyzableGroupIdentifierForRowAt indexPath: IndexPath
                ) -> AnyHashable? {
                return "sc_\(indexPath.section)"
            }
        }
        test.rootViewController = Controller()
        
        test.expect(for: 6)
        test.launch()
        self.wait(
            for: test.expectations,
            timeout: 999.0
        )
        
        XCTAssertEqual(test.results[0] as! String, "sc_0_0")
        XCTAssertEqual(test.results[1] as! String, "sc_3_7")
    }
}
