//
//  mainViewController.h
//  simpleFinance
//
//  Created by Eric Cao on 4/7/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LGGradientBackgroundView/LGGradientBackgroundView.h"

@interface mainViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *moneyLuckView;
@property (weak, nonatomic) IBOutlet UILabel *luckyText;

@property (strong, nonatomic)  UITableView *maintableView;
@property (strong, nonatomic) IBOutlet LGGradientBackgroundView *gradientView;
- (IBAction)skinChange:(id)sender;

@end

