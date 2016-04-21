//
//  dateSelectView.m
//  simpleFinance
//
//  Created by Eric Cao on 4/21/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "dateSelectView.h"
#import "global.h"

@interface dateSelectView()
@property (nonatomic, strong) UIView *pickerBack;
@property (nonatomic, strong) UIView *timeView;


@end
@implementation dateSelectView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.15f green:0.15f blue:0.15f alpha:0.75f];
        self.pickerBack = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - SCREEN_WIDTH*2/3, SCREEN_WIDTH, SCREEN_WIDTH*2/3)];
        self.pickerBack.backgroundColor = [UIColor colorWithRed:0.95f green:0.95f blue:0.95f alpha:0.95f];
        [self addSubview:self.pickerBack];
        
        CGFloat heightLeft = SCREEN_HEIGHT - self.pickerBack.frame.size.height;
        
        self.timeView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/10, heightLeft/4, SCREEN_WIDTH*4/5, heightLeft/2)];
        self.timeView.backgroundColor = [UIColor colorWithRed:0.95f green:0.95f blue:0.95f alpha:0.95f];
        [self addSubview:self.timeView];
        
        self.myDatePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, self.pickerBack.frame.size.width, self.pickerBack.frame.size.height)];
        
//        [self.myDatePicker setLocale:[NSLocale currentLocale]];
        [self.myDatePicker setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"zh_Hans_CN"]];
    
        // 设置时区
        [self.myDatePicker setTimeZone:[NSTimeZone localTimeZone]];
        
        // 设置当前显示时间
        [self.myDatePicker setDate:[NSDate date] animated:YES];

        // 设置UIDatePicker的显示模式
        [self.myDatePicker setDatePickerMode:UIDatePickerModeDate];
        // 当值发生改变的时候调用的方法
        [self.pickerBack addSubview:self.myDatePicker ];


    }
    return self;
}





/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
