//
//  summeryViewController.h
//  simpleFinance
//
//  Created by Eric Cao on 4/7/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#define weekDayBarHeight 40

#import <UIKit/UIKit.h>

@interface summeryViewController : UIViewController

@property BOOL isShowDaily;

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
@property (weak, nonatomic) IBOutlet UILabel *timeUnitLabel;
@property (weak, nonatomic) IBOutlet UILabel *incomeTitle;
@property (weak, nonatomic) IBOutlet UILabel *expenseTitle;
@property (weak, nonatomic) IBOutlet UILabel *surplusTitle;
@property (weak, nonatomic) IBOutlet UIButton *calendarButton;
@end
