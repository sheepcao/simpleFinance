//
//  mainViewController.h
//  simpleFinance
//
//  Created by Eric Cao on 4/7/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LGGradientBackgroundView/LGGradientBackgroundView.h"
#import "baseViewController.h"
#import "LuckyLabel.h"

@interface mainViewController : baseViewController
@property (weak, nonatomic) IBOutlet UILabel *titleTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *moneyBookText;

@property (weak, nonatomic) IBOutlet UIView *moneyLuckView;
@property (weak, nonatomic) IBOutlet LuckyLabel *luckyText;
@property (weak, nonatomic) IBOutlet UIButton *constellationButton;

@property (strong, nonatomic)  UITableView *maintableView;
//@property (strong, nonatomic) IBOutlet LGGradientBackgroundView *gradientView;
//- (IBAction)skinChange:(id)sender;
-(void)showingModel;
- (IBAction)configConstellation:(id)sender;
@end

