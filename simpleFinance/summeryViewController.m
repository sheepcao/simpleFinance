//
//  summeryViewController.m
//  simpleFinance
//
//  Created by Eric Cao on 4/7/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "summeryViewController.h"
#import "CommonUtility.h"
#import "calendarViewController.h"

@interface summeryViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *downLineHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *midLineHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *upLineHeight;
@property (strong, nonatomic) UILabel *monthEn;

@end

@implementation summeryViewController

-(void)makeTextColor:(UIColor *)myColor
{
    [self.dateLabel setTextColor:myColor];
    [self.monthIncome setTextColor:myColor];
    [self.monthExpense setTextColor:myColor];
    [self.monthSurplus setTextColor:myColor];
    [self.yearLabel setTextColor:myColor];
    [self.monthLabel setTextColor:myColor];
    [self.timeUnitLabel setTextColor:myColor];
    [self.incomeTitle setTextColor:myColor];
    [self.expenseTitle setTextColor:myColor];
    [self.surplusTitle setTextColor:myColor];
    [self.monthEn setTextColor:myColor];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.monthEn = [[UILabel alloc] initWithFrame:CGRectMake(self.yearLabel.center.x - 62, self.yearLabel.frame.origin.y + self.yearLabel.frame.size.height, 126, 40)];
    self.monthEn.font = [UIFont fontWithName:@"HelveticaNeue" size:22.5f];
    self.monthEn.adjustsFontSizeToFitWidth = YES;
    self.monthEn.textColor = normal;
    self.monthEn.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.monthEn];
    [self.monthEn setHidden:YES];
    
    NSString *today;
    if (!self.historyDate || [self.historyDate isEqualToString:@""]) {
        today =self.todayDate;
    }else
    {
        today =self.historyDate;
    }
//    [self weekDayStr:today];

    
    NSArray *dateParts = [today componentsSeparatedByString:@"-"];
    NSString *year = @"";
    NSString *month = @"";
    NSString *day = @"";
    if (dateParts.count>2) {
        year = dateParts[0];
        month = dateParts[1];
        day = dateParts[2];
    }
    
    if ([CommonUtility isSystemLangChinese]) {
        [self.timeUnitLabel setHidden:NO];
    }else
    {
        [self.timeUnitLabel setHidden:YES];
    }
    
    if (self.isShowDaily) {
        [self.timeUnitLabel setText:@"日"];
        [self.yearLabel setText:[NSString stringWithFormat:@"%@-%ld",year,(long)[month integerValue]]];
        [self.monthLabel setText:[NSString stringWithFormat:@"%ld",(long)[day integerValue]]];
        [self.dateLabel setText:@""];
        [self.dateLabel setHidden:YES];
        [self.calendarButton setHidden:YES];
        [self.expenseTitle setText:NSLocalizedString(@"日支出",nil)];
        [self.incomeTitle setText:NSLocalizedString(@"日收入",nil)];
        [self.surplusTitle setText:NSLocalizedString(@"日结余",nil)];
        
    }else
    {

        [self.timeUnitLabel setText:@"月"];
        [self.yearLabel setText:year];
        NSString *monthNow = [NSString stringWithFormat:@"%ld",(long)[month integerValue]];
        if ([CommonUtility isSystemLangChinese]) {
            [self.monthLabel setText:monthNow];

        }else
        {
            [self.monthLabel setHidden:YES];
            [self.monthEn setHidden:NO];
            [self.monthEn setText: NSLocalizedString(monthNow,nil)];
        }
        [self.dateLabel setText:[self weekDayStr:today]];
        [self.dateLabel setHidden:NO];
        [self.calendarButton setHidden:NO];
        [self.expenseTitle setText:NSLocalizedString(@"月支出",nil)];
        [self.incomeTitle setText:NSLocalizedString(@"月收入",nil)];
        [self.surplusTitle setText:NSLocalizedString(@"月结余",nil)];
    }
    
    NSLog(@"summeryViewController\n viewDidLoad");


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
//    NSCalendar *cal = [NSCalendar currentCalendar];
    NSCalendar *cal = [[NSCalendar alloc]
                                    initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *date = [NSDate date];
    NSDateComponents *comps = [cal components:(kCFCalendarUnitYear | NSCalendarUnitMonth | kCFCalendarUnitDay)
                                     fromDate:date];
    NSDate *today = [cal dateFromComponents:comps];
    return [self stringFromDate:today];
}
- (NSString *)stringFromDate:(NSDate *)date{
    NSCalendar *cal = [[NSCalendar alloc]
                       initWithCalendarIdentifier:NSCalendarIdentifierGregorian];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.calendar = cal;

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
    
//    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
   NSCalendar *currentCalendar = [[NSCalendar alloc]
     initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *_date = [currentCalendar dateFromComponents:comps];
    NSDateComponents *weekdayComponents = [currentCalendar components:NSCalendarUnitWeekday fromDate:_date];
    NSInteger week = [weekdayComponents weekday];
    switch (week) {
        case 1:
            weekDayStr = NSLocalizedString(@"星期日",nil);
            break;
        case 2:
            weekDayStr = NSLocalizedString(@"星期一",nil);
            break;
        case 3:
            weekDayStr = NSLocalizedString(@"星期二",nil);
            break;
        case 4:
            weekDayStr =NSLocalizedString(@"星期三",nil) ;
            break;
        case 5:
            weekDayStr = NSLocalizedString(@"星期四",nil);
            break;
        case 6:
            weekDayStr = NSLocalizedString(@"星期五",nil);
            break;
        case 7:
            weekDayStr = NSLocalizedString(@"星期六",nil);
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
