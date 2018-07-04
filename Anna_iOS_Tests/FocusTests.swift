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
                self.analyzer.enable(naming: "master")

                self.button = {
                    let
                    button = PathTestingButton()
                    self.analyzer.setSubAnalyzer(
                        button.analyzer,
                        for: "bt"
                    )
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
                detail.analyzer.enable(naming: "detail")
                self.navigationController?.pushViewController(
                    detail,
                    animated: false
                )
            }
        }
        let
        navigation = PathTestingNavigationController(rootViewController: Controller())
        navigation.analyzer.enable(naming: "nv")
        test.rootViewController = navigation
        
        test.expect()
        test.launch()
        self.wait(
            for: test.expectations,
            timeout: 1.0
        )
        
        XCTAssertEqual(test[0] as? Int, 42)
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
                self.analyzer.enable(naming: "master")
                self.view.addSubview(self.table)
                self.analyzer.setSubAnalyzer(
                    self.table.analyzer,
                    for: "table"
                )
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
                        cell.analyzer.enable(naming: "row")
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
                detail.analyzer.enable(naming: "detail")
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
        navigation.analyzer.enable(naming: "nv")
        test.rootViewController = navigation
        
        test.expect()
        test.launch()
        self.wait(
            for: test.expectations,
            timeout: 1.0
        )
        
        XCTAssertEqual(test[0] as? Int, 42)
    }
    
    func test_analyzer_activiated_with_standalone_name_should_handle_focus_marking_properly() {
        let
        test = PathTestCaseBuilder(with: self)
        test.task = ("""
        match(
          'master/table/cell/button/detail/ana-appeared',
          function(node) { return 42; }
        );
        """)
        class
            Controller : PathTestingViewController, UITableViewDelegate, UITableViewDataSource
        {
            class
                Cell : PathTestingTableViewCell
            {
                override
                init(
                    style: UITableViewCellStyle,
                    reuseIdentifier: String?
                    ) {
                    super.init(
                        style: style,
                        reuseIdentifier: reuseIdentifier
                    )
                    let
                    cell = self,
                    button = PathTestingButton(frame: cell.contentView.bounds)
                    cell.contentView.addSubview(button)
                    button.analyzer.enable(naming: "button")
                    
                    button.addTarget(
                        nil,
                        action: #selector(Controller.handleControlEvent),
                        for: .touchUpInside
                    )
                }
                required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
            }
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
                    Cell.self,
                    forCellReuseIdentifier: "r"
                )
                return table
            }()
            override func
                viewDidLoad() {
                super.viewDidLoad()
                self.analyzer.enable(naming: "master")
                self.view.addSubview(self.table)
                self.table.analyzer.enable(naming: "table")
            }
            override func
                viewDidAppear(_ animated: Bool) {
                super.viewDidAppear(animated)
                let
                cell = self.table.cellForRow(
                    at: IndexPath(row: 9, section: 0)
                ),
                button = cell?.contentView.subviews[0] as! PathTestingButton
                button.analyzer.markFocused()
                button.sendActions(for: .touchUpInside)
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
                cell.analyzer.enable(naming: "cell")
                return cell
            }
            func
                tableView(
                _ tableView: UITableView,
                numberOfRowsInSection section: Int
                ) -> Int {
                return 10
            }
            @objc func
                handleControlEvent() {
                let
                detail = PathTestingViewController()
                detail.analyzer.enable(naming: "detail")
                self.navigationController?.pushViewController(detail, animated: false)
            }
        }
        let
        navigation = UINavigationController(rootViewController: Controller())
        test.rootViewController = navigation

        test.expect(for: 1)
        test.launch()
        self.wait(
            for: test.expectations,
            timeout: 1.0
        )
        
        XCTAssertEqual(test[0] as? Int, 42)
    }
}
