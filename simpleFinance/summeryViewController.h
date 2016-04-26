//
//  summeryViewController.h
//  simpleFinance
//
//  Created by Eric Cao on 4/7/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface summeryViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic)  NSString *todayDate;
@property (strong, nonatomic)  NSString *historyDate;

@property (weak, nonatomic) IBOutlet UILabel *monthIncome;
@property (weak, nonatomic) IBOutlet UILabel *monthExpense;
@property (weak, nonatomic) IBOutlet UILabel *monthSurplus;

@property (weak, nonatomic) IBOutlet UILabel *monthBudget;
@property (weak, nonatomic) IBOutlet UILabel *budgetSurplus;
@property (weak, nonatomic) IBOutlet UIButton *budgetButton;
@property (weak, nonatomic) IBOutlet UILabel *yearLabel;
@property (weak, nonatomic) IBOutlet UILabel *monthLabel;
@end
