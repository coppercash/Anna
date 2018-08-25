//
//  MemoryManagementTests.m
//  Anna_iOS_Tests
//
//  Created by William on 2018/7/9.
//

#import <XCTest/XCTest.h>
#import "Anna_iOS_Tests-Swift.h"
#import <objc/runtime.h>

@interface MMTController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>
@end
@implementation MMTController

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{ return 0; }

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{ return [[UICollectionViewCell alloc] initWithFrame:collectionView.bounds]; }

@end

int a = 0;
@interface MemoryManagementTests : XCTestCase
@end
@implementation MemoryManagementTests

- (void)test_collection_view_enabled_analyzer_should_be_released_properly {
    __weak __auto_type
    weakRef = (MMTController *)nil;
    @autoreleasepool {
        __auto_type const
        view = [[ANAPathTestingCollectionView alloc] initWithFrame:UIScreen.mainScreen.bounds
                                              collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
        __auto_type const
        controller = [[MMTController alloc] init];
        [controller.view addSubview:view];
        view.dataSource = controller;
        view.delegate = controller;
        [view.ana_analyzer enableNaming:@"collection"];

        weakRef = controller;
    }
    XCTAssertNil(weakRef);
}

@end
