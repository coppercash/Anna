//
//  PathTests.swift
//  Anna_iOS_Tests
//
//  Created by William on 2018/4/18.
//

import XCTest
import Anna

class PathTests: XCTestCase {
    
    func testExample() {
        let
        test = PathTestCaseBuilder(with: self)
        test.defaultScript = 
        "const match = require('anna').default().match;" +
        "match(" +
        "  'vc/bt/event'," +
        "  function() { return 42; }" +
        ");"
        class
        Controller : PathTestingViewController
        {
            var
            button :UIButton? = nil
            override func
                viewDidLoad() {
                super.viewDidLoad()
                let
                button = PathTestingButton()
                let
                analyzer = UIControlAnalyzer(with: button)
                analyzer.hook(button)
                button.analyzer = analyzer
                self.view.addSubview(button)
                self.button = button
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
}
