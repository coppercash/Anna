//
//  SecondViewController.m
//  CocoapodsDemo
//
//  Created by William on 28/07/2017.
//  Copyright © 2017 coppercash. All rights reserved.
//

#import "SecondViewController.h"
#import <Anna/Anna.h>
#import <Anna/Anna-Swift.h>

@interface SecondViewController ()

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.ana.analyze();
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

@interface SecondViewController (ANAAnalyzable) <ANAAnalyzable>
@end
@implementation SecondViewController (ANAAnalyzable)

+ (void)ana_registerAnalyticsPointsWithRegistrar:(id<ANARegistrationRecording>)registrar {
    registrar
    .point(^(id<ANAMethodPointBuilding> _) { _
        .selector(@selector(viewDidLoad))
        ;
    })
    ;
}

@end
