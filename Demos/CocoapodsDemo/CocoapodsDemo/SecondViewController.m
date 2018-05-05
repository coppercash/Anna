//
//  SecondViewController.m
//  CocoapodsDemo
//
//  Created by William on 28/07/2017.
//  Copyright © 2017 coppercash. All rights reserved.
//

#import "SecondViewController.h"
#import <Anna/Anna-Swift.h>

@interface SecondViewController () <ANAAnalyzable>
@end

@implementation SecondViewController
@synthesize ana_analyzer;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.ana_analyzer =
    [ANAAnalyzer analyzerHookingDelegate:self
                                  naming:@"second_view_controller"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
