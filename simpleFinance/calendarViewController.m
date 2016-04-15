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

@interface calendarViewController ()<FSCalendarDataSource,FSCalendarDelegate,FSCalendarDataSourceDeprecatedProtocol>

@property (weak, nonatomic) FSCalendar *calendar;


@end

@implementation calendarViewController

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
    calendar.allowsMultipleSelection = YES;
    calendar.firstWeekday = 2;
    calendar.appearance.caseOptions = FSCalendarCaseOptionsWeekdayUsesDefaultCase|FSCalendarCaseOptionsHeaderUsesDefaultCase;
    calendar.appearance.eventColor = [UIColor redColor];
    calendar.appearance.headerTitleColor = TextColor;
    calendar.appearance.weekdayTextColor = TextColor;
    calendar.appearance.titleDefaultColor = [UIColor colorWithRed:0.24 green:0.24 blue:0.24 alpha:1.0];
    calendar.appearance.selectionColor = [UIColor colorWithRed:223/255.0f green:162/255.0f blue:57/255.0f alpha:1.0f];

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

-(void)closeVC
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)calendar:(FSCalendar *)calendar hasEventForDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date1 = [dateFormatter dateFromString:@"2016-04-01"];
    NSDate *date2 = [dateFormatter dateFromString:@"2016-04-03"];
    NSLog(@"%@", date1);
    NSArray *dates = @[date1,date2];
    for (int i = 0; i<dates.count; i++) {
        if ([date isEqualToDate:dates[i]])
        {
            return YES;
        }
    }

    return NO;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
