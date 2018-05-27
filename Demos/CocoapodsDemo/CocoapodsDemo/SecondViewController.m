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
@synthesize ana_analyzer = _ana_analyzer;

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (!(self = [super initWithCoder:aDecoder])) { return nil; }
    _ana_analyzer = [ANAAnalyzer analyzerWithDelegate:self];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.ana_analyzer enableWithKey:@"second_view_controller"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
