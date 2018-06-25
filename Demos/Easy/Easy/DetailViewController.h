//
//  DetailViewController.h
//  Eazy
//
//  Created by William on 2018/6/24.
//  Copyright © 2018 coppercash. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Anna/Anna-Swift.h>

@interface DetailViewController : UIViewController <ANAAnalyzable>

@property (strong, nonatomic) NSDate *detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

