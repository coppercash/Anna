//
//  CollectionViewTests.swift
//  Anna_iOS_Tests
//
//  Created by William on 2018/5/26.
//

import XCTest
import Anna

class CollectionViewTests: XCTestCase {
    
    func test_collectionViewSectionShouldReportAppeared() {
        let
        test = PathTestCaseBuilder(with: self)
        
        test.task = ("""
        match(
          'tb/sc_0/ana-appeared',
          function(node) { return 42; }
        );
        match(
          'tb/sc_19/ana-appeared',
          function(node) { return 43; }
        );
        """)
        class
            Controller : UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, SectionAnalyzableCollectionViewDelegate
        {
            lazy var
            collection :PathTestingCollectionView = {
                let
                superview = self.view!;
                let
                collection = PathTestingCollectionView(
                    frame: superview.bounds,
                    collectionViewLayout: UICollectionViewFlowLayout()
                )
                collection.delegate = self
                collection.dataSource = self
                collection.register(
                    PathTestingCollectionViewCell.self,
                    forCellWithReuseIdentifier: "r"
                )
                return collection
            }()
            override func
                viewDidLoad() {
                super.viewDidLoad()
                self.view.addSubview(self.collection)
                self.collection.analyzer.enable(with: "tb")
            }
            override func
                viewDidAppear(_ animated: Bool) {
                super.viewDidAppear(animated)
                self.collection.scrollToItem(
                    at: IndexPath(row: 0, section: 19),
                    at: .bottom,
                    animated: false
                )
            }
            func
                collectionView(
                _ collectionView: UICollectionView,
                cellForItemAt indexPath: IndexPath
                ) -> UICollectionViewCell {
                return collectionView.dequeueReusableCell(
                    withReuseIdentifier: "r",
                    for: indexPath
                )
            }
            func
                collectionView(
                _ collectionView: UICollectionView,
                numberOfItemsInSection section: Int
                ) -> Int {
                return 1
            }
            func
                numberOfSections(
                in collectionView: UICollectionView
                ) -> Int {
                return 20
            }
            func
                collectionView(
                _ collectionView: UICollectionView & AnalyzerReadable,
                analyticNameFor section :Int
                ) -> String? {
                return "sc_\(section)"
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
