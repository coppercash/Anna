//
//  DetailViewController.m
//  Eazy
//
//  Created by William on 2018/6/24.
//  Copyright © 2018 coppercash. All rights reserved.
//

#import "DetailViewController.h"
#import <Easy/Easy-Swift.h>

@interface DetailViewController ()

@end

@implementation DetailViewController
@synthesize ana_analyzer = _ana_analyzer;

- (id<ANAAnalyzing>)ana_analyzer { return _ana_analyzer ?: (_ana_analyzer = [ANAAnalyzer analyzerWithDelegate:self]); }

+ (NSSet<NSString *> *)subAnalyzableKeys {
    return [NSSet setWithObjects:@"detailDescriptionButton", nil];
}

- (void)dealloc {
    [_ana_analyzer detach];
}

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.detailItem) {
        [self.detailDescriptionButton setTitle:self.detailItem.description
                                      forState:UIControlStateNormal];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    [self.ana_analyzer observeObject:self.detailDescriptionButton
                          forKeyPath:@"titleLabel.text"];
    [self.ana_analyzer enableNaming:@"detail"];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Managing the detail item

- (void)setDetailItem:(NSDate *)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}

@end
