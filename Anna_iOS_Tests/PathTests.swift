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
        """
        match(
        'vc/bt/uievent',
        function() { return 42; }
        );
        """
        class
        Controller : PathTestingViewController
        {
            class
                Button : PathTestingButton
            {
                override func
                    didMoveToSuperview() {
                    guard let _ = self.superview else {
                        return
                    }
                    let
                    analyzer = UIControlAnalyzer(with: self)
                    analyzer.hook(self)
                    self.analyzer = analyzer
                }
                override func
                    pathNodeName() -> String {
                    return "bt"
                }
            }
            var
            button :UIButton? = nil
            override func
                viewDidLoad() {
                super.viewDidLoad()
                
                self.analyzer = Analyzer(with: self)
                
                let
                button = Button()
                self.view.addSubview(button)
                self.button = button
            }
            override func
                viewDidAppear(_ animated: Bool) {
                super.viewDidAppear(animated)
                self.button?.sendActions(for: .touchUpInside)
            }
            override func
                pathNodeName() -> String {
                return "vc"
            }
        }
        test.rootViewController = Controller()

        test.expect()
        test.launch()
        self.wait(
            for: test.expectations,
            timeout: 99999999.0
        )
        
        XCTAssertEqual(test.results[0] as! Int, 42)
    }
}
