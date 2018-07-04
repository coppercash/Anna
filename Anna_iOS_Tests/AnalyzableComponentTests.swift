//
//  AnalyzableComponentTests.swift
//  Anna_iOS_Tests
//
//  Created by William on 2018/6/10.
//

import XCTest
import Anna

class AnalyzableComponentTests: XCTestCase {
    
    func test_should_name_sub_analyzers_by_keys() {
        let
        test = PathTestCaseBuilder(with: self)
        test.task = ("""
        match(
          'vc/view/buttons/touch-up-inside',
          function(n) { return n.index; }
        );
        """)
        class
            Controller : UIViewController, AnalyzableObject
        {
            lazy var
            analyzer :Analyzing = { Analyzer.analyzer(with: self) }()
            deinit {
                self.analyzer.detach()
            }
            override func
                loadView() {
                self.view = View(frame: UIScreen.main.bounds)
            }
            override func
                viewDidLoad() {
                super.viewDidLoad()
                self.analyzer.enable(naming: "vc")
            }
            override func
                viewDidAppear(_ animated: Bool) {
                super.viewDidAppear(animated)
                let
                view = self.view as! View
                for button in view.buttons {
                    button.sendActions(for: .touchUpInside)
                }
            }
            static let
            subAnalyzableKeys = Set([#keyPath(view)])
            class
                View : UIView, AnalyzableObject
            {
                lazy var
                analyzer :Analyzing = { Analyzer.analyzer(with: self) }()
                @objc lazy var
                buttons :[Button] = {
                    let
                    buttons = [
                        Button(frame: self.bounds),
                        Button(frame: self.bounds),
                        ]
                    return buttons
                }()
                deinit {
                    self.analyzer.detach()
                }
                override func
                    didMoveToSuperview() {
                    for button in self.buttons {
                        if let
                            superview = self.superview,
                            button.superview == nil
                        {
                            superview.addSubview(button)
                        }
                    }
                }
                static let
                subAnalyzableKeys = Set([#keyPath(buttons)])
                class
                    Button : UIButton, Analyzable
                {
                    lazy var
                    analyzer :Analyzing = { Analyzer.analyzer(with: self) }()
                    deinit {
                        self.analyzer.detach()
                    }
                }
            }
        }
        test.rootViewController = Controller()
        
        test.expect(for: 2)
        test.launch()
        self.wait(
            for: test.expectations,
            timeout: 1.0
        )
        
        XCTAssertEqual(test[0] as? Int, 0)
        XCTAssertEqual(test[1] as? Int, 1)
    }

}
