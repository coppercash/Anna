//
//  AnalyzableTableView.swift
//  Anna
//
//  Created by William on 2018/6/25.
//

import UIKit
import Anna

class AnalyzableTableView : UITableView, Analyzable {
    lazy var analyzer: Analyzing = { Analyzer.analyzer(with: self) }()
    deinit { self.analyzer.detach() }
}

class AnalyzableTableViewCell : UITableViewCell, Analyzable {
    lazy var analyzer: Analyzing = { Analyzer.analyzer(with: self) }()
    deinit { self.analyzer.detach() }
}
