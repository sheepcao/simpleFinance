//
//  summeryViewController.m
//  simpleFinance
//
//  Created by Eric Cao on 4/7/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "summeryViewController.h"
#import "calendarViewController.h"

@interface summeryViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *downLineHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *midLineHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *upLineHeight;


@end

@implementation summeryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSString *today;
    if (!self.historyDate || [self.historyDate isEqualToString:@""]) {
        today = [self weekDayStr:self.todayDate];
    }else
    {
        today = [self weekDayStr:self.historyDate];
    }
    
    NSArray *dateParts = [self.todayDate componentsSeparatedByString:@"-"];
    NSString *year = @"";
    NSString *month = @"";
    NSString *day = @"";
    if (dateParts.count>2) {
        year = dateParts[0];
        month = dateParts[1];
        day = dateParts[2];
    }
    
    if (self.isShowDaily) {
        [self.timeUnitLabel setText:@"日"];
        [self.yearLabel setText:[NSString stringWithFormat:@"%@-%ld",year,(long)[month integerValue]]];
        [self.monthLabel setText:[NSString stringWithFormat:@"%ld",(long)[day integerValue]]];
        [self.dateLabel setText:@""];
        [self.dateLabel setHidden:YES];
        [self.calendarButton setHidden:YES];
        [self.expenseTitle setText:@"日支出"];
        [self.incomeTitle setText:@"日收入"];
        [self.surplusTitle setText:@"日结余"];
        
    }else
    {
        [self.timeUnitLabel setText:@"月"];
        [self.yearLabel setText:year];
        [self.monthLabel setText:[NSString stringWithFormat:@"%ld",(long)[month integerValue]]];
        [self.dateLabel setText:today];
        [self.dateLabel setHidden:NO];
        [self.calendarButton setHidden:NO];
        [self.expenseTitle setText:@"月支出"];
        [self.incomeTitle setText:@"月收入"];
        [self.surplusTitle setText:@"月结余"];
    }
    
    NSLog(@"summeryViewController\viewDidLoad");


}
- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    [self.downLineHeight setConstant:0.6f];
    [self.midLineHeight setConstant:0.6f];
    [self.upLineHeight setConstant:0.6f];
    
    [self.view setNeedsUpdateConstraints];
    
    //fit for daily or monthly
    
    
    [self.view layoutIfNeeded];
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString *)todayDate
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    
    NSDate *date = [NSDate date];
    NSDateComponents *comps = [cal components:(kCFCalendarUnitYear | NSCalendarUnitMonth | kCFCalendarUnitDay)
                                     fromDate:date];
    NSDate *today = [cal dateFromComponents:comps];
    return [self stringFromDate:today];
}
- (NSString *)stringFromDate:(NSDate *)date{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //zzz表示时区，zzz可以删除，这样返回的日期字符将不包含时区信息。
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *destDateString = [dateFormatter stringFromDate:date];
    return destDateString;
    
}

- (NSString*)weekDayStr:(NSString *)date
{
    NSString *weekDayStr = nil;
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    
    
    NSArray *array = [date componentsSeparatedByString:@"-"];
    if (array.count >= 3) {
        NSInteger year = [[array objectAtIndex:0] integerValue];
        NSInteger month = [[array objectAtIndex:1] integerValue];
        NSInteger day = [[array objectAtIndex:2] integerValue];
        [comps setYear:year];
        [comps setMonth:month];
        [comps setDay:day];
    }
    
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];

    NSDate *_date = [currentCalendar dateFromComponents:comps];
    NSDateComponents *weekdayComponents = [currentCalendar components:NSCalendarUnitWeekday fromDate:_date];
    NSInteger week = [weekdayComponents weekday];
    switch (week) {
        case 1:
            weekDayStr = @"星期日";
            break;
        case 2:
            weekDayStr = @"星期一";
            break;
        case 3:
            weekDayStr = @"星期二";
            break;
        case 4:
            weekDayStr = @"星期三";
            break;
        case 5:
            weekDayStr = @"星期四";
            break;
        case 6:
            weekDayStr = @"星期五";
            break;
        case 7:
            weekDayStr = @"星期六";
            break;
        default:
            weekDayStr = @"";
            break;
    }
    return [NSString stringWithFormat:@"%@       %@",date,weekDayStr];
}


- (IBAction)planMoney:(id)sender {
    NSLog(@"adasdasd");
}
- (IBAction)showCalendar:(id)sender {
    
    calendarViewController *calendarVC = [[calendarViewController alloc] initWithNibName:@"calendarViewController" bundle:nil];
    [self.navigationController pushViewController:calendarVC animated:YES];
}

@end
