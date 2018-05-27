//
//  FirstViewController.swift
//  CocoapodsDemo
//
//  Created by William on 28/07/2017.
//  Copyright © 2017 coppercash. All rights reserved.
//

import UIKit
import Anna

class FirstViewController: UIViewController, Analyzable {

    lazy var analyzer: Analyzing = { Analyzer.analyzer(with: self) }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.analyzer.enable(with: "first_view_controller")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
