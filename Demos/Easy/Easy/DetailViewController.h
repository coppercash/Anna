//
//  DetailViewController.h
//  Eazy
//
//  Created by William on 2018/6/24.
//  Copyright © 2018 coppercash. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) NSDate *detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

