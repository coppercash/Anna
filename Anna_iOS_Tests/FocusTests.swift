//
//  FocusTests.swift
//  Anna_iOS_Tests
//
//  Created by William on 2018/5/19.
//

import XCTest
import Anna

class FocusTests: XCTestCase {
    
    func test_button() {
        let
        test = PathTestCaseBuilder(with: self)
        test.task =
        """
        match(
        'master/bt/detail/ana-appeared',
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
                self.becomeAnalysisObject(named: "master")
                
                self.button = {
                    let
                    button = PathTestingButton()
                    button.becomeAnalysisObject(named: "bt")
                    button.addTarget(
                        self,
                        action: #selector(handleControlEvent),
                        for: .touchUpInside
                    )
                    return button
                }()
                self.view.addSubview(self.button!)
            }
            override func
                viewDidAppear(_ animated: Bool) {
                super.viewDidAppear(animated)
                self.button?.sendActions(for: .touchUpInside)
            }
            @objc func
                handleControlEvent() {
                let
                detail = PathTestingViewController()
                detail.becomeAnalysisObject(named: "detail")
                self.navigationController?.pushViewController(
                    detail,
                    animated: false
                )
            }
        }
        let
        navigation = PathTestingNavigationController(rootViewController: Controller())
        navigation.becomeAnalysisObject(named: "nv")
        test.rootViewController = navigation
        
        test.expect()
        test.launch()
        self.wait(
            for: test.expectations,
            timeout: 1.0
        )
        
        XCTAssertEqual(test.results[0] as! Int, 42)
    }
    
    func test_table() {
        let
        test = PathTestCaseBuilder(with: self)
        test.task =
        """
        match(
        'master/table/19/row/detail/ana-appeared',
        function() { return 42; }
        );
        """
        class
            Controller : PathTestingViewController, UITableViewDelegate, UITableViewDataSource, SectionAnalyzableTableViewDelegate
        {
            lazy var
            table :UITableView = {
                let
                superview = self.view!
                let
                table = PathTestingTableView(frame: superview.bounds)
                table.delegate = self
                table.dataSource = self
                table.becomeAnalysisObject(named: "table")
                return table
            }()
            override func
                viewDidLoad() {
                super.viewDidLoad()
                self.becomeAnalysisObject(named: "master")
                self.view.addSubview(self.table)
            }
            override func
                viewDidAppear(_ animated: Bool) {
                super.viewDidAppear(animated)
                let
                indexPath = IndexPath(row: 0, section: 19)
                self.table.scrollToRow(
                    at: indexPath,
                    at: .bottom,
                    animated: false
                )
                self.table.selectRow(
                    at: indexPath,
                    animated: false,
                    scrollPosition: .none
                )
                self.table.delegate?.tableView?(
                    self.table,
                    didSelectRowAt: indexPath
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
                        cell.becomeAnalysisObject(named: "row")
                        return cell
                    }()
                return cell
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
                _ tableView: UITableView,
                didSelectRowAt indexPath: IndexPath
                ) {
                let
                detail = PathTestingViewController()
                detail.becomeAnalysisObject(named: "detail")
                self.navigationController?.pushViewController(
                    detail,
                    animated: false
                )
            }
            func
                tableView(
                _ tableView: UITableView & AnalyzerReadable,
                analyticNameFor section :Int
                ) -> String? {
                return "\(section)"
            }
        }
        let
        navigation = PathTestingNavigationController(rootViewController: Controller())
        navigation.becomeAnalysisObject(named: "nv")
        test.rootViewController = navigation
        
        test.expect()
        test.launch()
        self.wait(
            for: test.expectations,
            timeout: 1.0
        )
        
        XCTAssertEqual(test.results[0] as! Int, 42)
    }
}