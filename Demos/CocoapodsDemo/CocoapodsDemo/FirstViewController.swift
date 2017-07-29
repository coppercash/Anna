//
//  FirstViewController.swift
//  CocoapodsDemo
//
//  Created by William on 28/07/2017.
//  Copyright © 2017 coppercash. All rights reserved.
//

import UIKit
import Anna

class FirstViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.ana.analyze()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension FirstViewController : EasyAnalyzable {
    static func registerAnalyticsPoints(with registrar: EasyRegistering.Registrar) {
        registrar
        .point { $0
            .selector(#selector(viewDidLoad))
            .set("from", String(describing: self))
        }
    }
}
