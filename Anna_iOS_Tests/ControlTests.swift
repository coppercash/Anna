//
//  ControlTests.swift
//  Anna_iOS_Tests
//
//  Created by William on 2018/5/22.
//

import XCTest
import Anna

class ControlTests: XCTestCase {
    
    func test_button() {
        let
        test = PathTestCaseBuilder(with: self)
        test.task =
        """
        match(
        'vc/bt/touch-up-inside',
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
                self.analyzer.enable(with: "vc")
                
                self.button = {
                    let
                    button = PathTestingButton()
                    self.analyzer.setSubAnalyzer(
                        button.analyzer,
                        for: "bt"
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
    
    func test_unownedButtonShouldReportNoAppearingEvent() {
        let
        test = PathTestCaseBuilder(with: self)
        test.task =
        """
        match(
        'vc/ana-appeared',
        function() { return 42; }
        );
        match(
        'vc/touch-up-inside',
        function() { return 43; }
        );
        """
        class
            Controller : PathTestingViewController
        {
            lazy var
            button :UIButton = UIButton()
            override func
                viewDidLoad() {
                super.viewDidLoad()
                self.analyzer.enable(with: "vc")
                self.view.addSubview(self.button)
                self.analyzer.hook(self.button)
            }
            override func
                viewDidAppear(_ animated: Bool) {
                super.viewDidAppear(animated)
                self.button.sendActions(for: .touchUpInside)
            }
            deinit {
                self.analyzer.detach()
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
