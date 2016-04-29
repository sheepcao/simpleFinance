//
//  calendarViewController.m
//  simpleFinance
//
//  Created by Eric Cao on 4/15/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "calendarViewController.h"
#import "FSCalendar.h"
#import "global.h"
#import "topBarView.h"
#import "CommonUtility.h"
#import "historyViewController.h"

@interface calendarViewController ()<FSCalendarDataSource,FSCalendarDelegate,FSCalendarDataSourceDeprecatedProtocol>

@property (weak, nonatomic) FSCalendar *calendar;
@property (nonatomic,strong) FMDatabase *db;
@property (nonatomic,strong) NSMutableArray *eventDateArray;

@end

@implementation calendarViewController
@synthesize db;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    topBarView *topbar = [[topBarView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, topRowHeight+8)];
    topbar.backgroundColor = [UIColor clearColor];
    [topbar.titleLabel  setText:@"帐目日历"];
    [self.view addSubview:topbar];
    
    UIButton * closeViewButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 34, 60, 40)];
    closeViewButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    closeViewButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [closeViewButton setTitle:@"返回" forState:UIControlStateNormal];
    [closeViewButton setTitleColor:   [UIColor whiteColor]forState:UIControlStateNormal];
    [closeViewButton addTarget:self action:@selector(closeVC) forControlEvents:UIControlEventTouchUpInside];
    closeViewButton.backgroundColor = [UIColor clearColor];
    [topbar addSubview:closeViewButton];
    
    
    FSCalendar *calendar = [[FSCalendar alloc] initWithFrame:CGRectMake(0,  topRowHeight+10, SCREEN_WIDTH, SCREEN_HEIGHT- topRowHeight-10)];
    calendar.backgroundColor = [UIColor clearColor];
    calendar.dataSource = self;
    calendar.delegate = self;
    calendar.pagingEnabled = NO; // important
    calendar.allowsMultipleSelection = NO;
    calendar.firstWeekday = 2;
    calendar.appearance.caseOptions = FSCalendarCaseOptionsWeekdayUsesDefaultCase|FSCalendarCaseOptionsHeaderUsesDefaultCase;
    calendar.appearance.eventColor = [UIColor redColor];
    calendar.appearance.headerTitleColor = TextColor;
    calendar.appearance.weekdayTextColor = TextColor;
    calendar.appearance.titleDefaultColor = [UIColor colorWithRed:0.24 green:0.24 blue:0.24 alpha:1.0];
//    calendar.appearance.selectionColor = [UIColor colorWithRed:223/255.0f green:162/255.0f blue:57/255.0f alpha:1.0f];
    calendar.appearance.selectionColor = [UIColor clearColor];
    calendar.appearance.titleSelectionColor = calendar.appearance.titleDefaultColor;

    UIFontDescriptor *monthFontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                                @{UIFontDescriptorFamilyAttribute: @"Helvetica Neue",
                                                  UIFontDescriptorNameAttribute:@"HelveticaNeue-Italic",
                                                  UIFontDescriptorSizeAttribute: [NSNumber numberWithFloat: (int)(SCREEN_WIDTH/22)]
                                                  }];
    UIFontDescriptor *dayFontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                                @{UIFontDescriptorFamilyAttribute: @"Helvetica Neue",
                                                  UIFontDescriptorNameAttribute:@"HelveticaNeue-MediumItalic",
                                                  UIFontDescriptorSizeAttribute: [NSNumber numberWithFloat: (int)(SCREEN_WIDTH/28)]
                                                  }];
    
    calendar.appearance.headerTitleFont = [UIFont fontWithDescriptor:monthFontDescriptor size:0.0f];
    calendar.appearance.weekdayFont = [UIFont fontWithDescriptor:dayFontDescriptor size:0.0f];
    
//    calendar.appearance.subtitleFont = [UIFont fontWithDescriptor:dayFontDescriptor size:0.0f];

    [self.view addSubview:calendar];
    self.calendar = calendar;
    

    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self prepareData];
    [self.calendar reloadData];
}

-(void)prepareData
{
    if (!self.eventDateArray) {
        self.eventDateArray = [[NSMutableArray alloc] init];
    }else
    {
        [self.eventDateArray removeAllObjects];
    }
    
    db = [[CommonUtility sharedCommonUtility] db];
    if (![db open]) {
        NSLog(@"mainVC/Could not open db.");
        return;
    }

    FMResultSet *rs = [db executeQuery:@"select DISTINCT target_date from ITEMINFO"];
    while ([rs next]) {
        
        NSString *dateString = [rs stringForColumn:@"target_date"];
        NSArray *timeParts = [dateString componentsSeparatedByString:@" "];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSCalendar *cal = [[NSCalendar alloc]
                           initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        dateFormatter.calendar = cal;
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *date = [dateFormatter dateFromString:timeParts[0]];

        if(![self.eventDateArray containsObject:date])
        {
            [self.eventDateArray addObject:date];
        }
        
    }
    [db close];
}

-(void)closeVC
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)calendar:(FSCalendar *)calendar hasEventForDate:(NSDate *)date
{
    
    for (NSDate *eventDate in self.eventDateArray) {
        if ([date isEqualToDate:eventDate])
        {
            return YES;
        }
    }
   
    return NO;
}

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date
{
    NSDate *today = [NSDate date];
    
    NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
    [dateFormatter1 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSCalendar *cal = [[NSCalendar alloc]
                       initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    dateFormatter1.calendar = cal;
    
    NSString *selectString = [dateFormatter1 stringFromDate:date];
    NSString *todayString = [dateFormatter1 stringFromDate:today];
    
    NSString *selectDayString = [selectString componentsSeparatedByString:@" "][0];
    NSString *todayDayString = [todayString componentsSeparatedByString:@" "][0];

    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
    [dateFormatter2 setDateFormat:@"yyyy-MM-dd"];
     dateFormatter2.calendar = cal;
    
    NSDate *todayDay = [dateFormatter2 dateFromString:todayDayString];
    NSDate *selectedDay = [dateFormatter2 dateFromString:selectDayString];

    
    if ([selectedDay compare:todayDay] == NSOrderedDescending) {
        NSLog(@"date is later than today");
        return;
    } else if ([selectedDay compare:todayDay] == NSOrderedAscending) {
        NSLog(@"date is earlier than today");
        
        historyViewController *historyVC = [[historyViewController alloc] initWithNibName:@"historyViewController" bundle:nil];
        historyVC.recordDate = selectDayString;
        [self.navigationController pushViewController:historyVC animated:YES];
        return;
    } else {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    


}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
