//
//  CommonUtility.m
//  ActiveWorld
//
//  Created by Eric Cao on 10/30/14.
//  Copyright (c) 2014 Eric Cao/Mady Kou. All rights reserved.
//


#import "CommonUtility.h"
#import "itemObj.h"

@implementation CommonUtility

@synthesize myAudioPlayer;
@synthesize db;

+(CommonUtility *)sharedCommonUtility
{
    static CommonUtility *singleton;
    static dispatch_once_t token;
    dispatch_once(&token,^{
        singleton = [[CommonUtility alloc] init];
    });
    return singleton;
}

-(id)init
{
    self = [super init];
    if (self) {
        NSString *docsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSString *dbPath = [docsPath stringByAppendingPathComponent:@"JianBu.db"];
        NSLog(@"dbPath:%@",dbPath);
        db = [FMDatabase databaseWithPath:dbPath];
    }
    return self;
}


-(NSDateFormatter *)dateFormatter
{
    NSCalendar *cal = [[NSCalendar alloc]
                       initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    _dateFormatter.calendar = cal;
    return _dateFormatter;
}

-(NSString *)firstMonthDate
{
//    NSCalendar *cal = [NSCalendar currentCalendar];
    NSCalendar *cal = [[NSCalendar alloc]
                       initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDate *date = [NSDate date];
    
    NSDateComponents * currentDateComponents = [cal components: kCFCalendarUnitYear | NSCalendarUnitMonth fromDate: date];
    NSDate * startOfMonth = [cal dateFromComponents: currentDateComponents];
//    NSDate * endOfLastMonth = [startOfMonth dateByAddingTimeInterval: -1]; // One second before the start of this month

    return    [self stringFromDate:startOfMonth];
}

-(NSString *)lastMonthDate
{
//    NSCalendar *cal = [NSCalendar currentCalendar];
    NSCalendar *cal = [[NSCalendar alloc]
                       initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate * plusOneMonthDate = [self dateByAddingMonths: 1];
    NSDateComponents * plusOneMonthDateComponents = [cal components: kCFCalendarUnitYear | NSCalendarUnitMonth fromDate: plusOneMonthDate];
    NSDate * endOfMonth = [[cal dateFromComponents: plusOneMonthDateComponents] dateByAddingTimeInterval: -1]; // next month
    
    return [self stringFromDate:endOfMonth];
}
-(NSString *)firstNextMonthDate
{
//    NSCalendar *cal = [NSCalendar currentCalendar];
    NSCalendar *cal = [[NSCalendar alloc]
                       initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate * plusOneMonthDate = [self dateByAddingMonths: 1];
    NSDateComponents * plusOneMonthDateComponents = [cal components: kCFCalendarUnitYear | NSCalendarUnitMonth fromDate: plusOneMonthDate];
    NSDate * endOfMonth = [cal dateFromComponents: plusOneMonthDateComponents]; // next month

    return [self stringFromDate:endOfMonth];
}
//-(NSString *)oneDayBeforeDate:(NSString *)date
//{
//    NSDate *srcDate = [self dateFromString:date];
//    NSDate * oneDayBefor = [srcDate dateByAddingTimeInterval: -1]; // One second before the start of this month
//    return [self stringFromDate:oneDayBefor];
//
//}
//-(NSString *)oneDayAfterDate:(NSString *)date
//{
//    NSDate *srcDate = [self dateFromString:date];
//    NSDate * oneDayBefor = [srcDate dateByAddingTimeInterval: -1]; // One second before the start of this month
//    return [self stringFromDate:oneDayBefor];
//    
//}
- (NSDate *) dateByAddingMonths: (NSInteger) monthsToAdd
{
//    NSCalendar * calendar = [NSCalendar currentCalendar];
    NSCalendar *calendar = [[NSCalendar alloc]
                       initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *date = [NSDate date];

    NSDateComponents * months = [[NSDateComponents alloc] init];
    [months setMonth: monthsToAdd];
    
    return [calendar dateByAddingComponents: months toDate: date options: 0];
}
- (NSString *) dateByAddingDays: (NSString *)srcDate andDaysToAdd:(NSInteger) daysToAdd
{
//    NSCalendar * calendar = [NSCalendar currentCalendar];
    NSCalendar *calendar = [[NSCalendar alloc]
                            initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *day = [self dateFromString:srcDate];
    
    NSDateComponents * days = [[NSDateComponents alloc] init];
    [days setDay: daysToAdd];
    NSDate *dstDate = [calendar dateByAddingComponents: days toDate: day options: 0];
    return [self stringFromDate:dstDate];
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

-(NSString *)tomorrowDate
{
//    NSCalendar *cal = [NSCalendar currentCalendar];
    NSCalendar *cal = [[NSCalendar alloc]
                       initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *date = [NSDate date];
    NSDateComponents *comps = [cal components:(kCFCalendarUnitYear | NSCalendarUnitMonth | kCFCalendarUnitDay)
                                     fromDate:date];
    
    NSDate *today = [cal dateFromComponents:comps];
    NSDate *tomorrow = [today dateByAddingTimeInterval:(24*60*60)];
    
    return [self stringFromDate:tomorrow];
}
-(NSString *)yesterdayDate
{
//    NSCalendar *cal = [NSCalendar currentCalendar];
    NSCalendar *cal = [[NSCalendar alloc]
                       initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *date = [NSDate date];
    NSDateComponents *comps = [cal components:(kCFCalendarUnitYear | NSCalendarUnitMonth | kCFCalendarUnitDay)
                                     fromDate:date];
    
    NSDate *today = [cal dateFromComponents:comps];
    NSDate *yesterday = [today dateByAddingTimeInterval:(-24*60*60)];
    
    return [self stringFromDate:yesterday];
}

-(NSDate *)dateFromString:(NSString *)pstrDate
{
    NSDateFormatter *df1 = [[NSDateFormatter alloc] init];
    NSCalendar *cal = [[NSCalendar alloc]
                       initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    df1.calendar = cal;
    [df1 setDateFormat:@"yyyy-MM-dd"];
    NSDate *dtPostDate = [df1 dateFromString:pstrDate];
    return dtPostDate;
}
- (NSString *)stringFromDate:(NSDate *)date{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSCalendar *cal = [[NSCalendar alloc]
                       initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    dateFormatter.calendar = cal;
    //zzz表示时区，zzz可以删除，这样返回的日期字符将不包含时区信息。
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *destDateString = [dateFormatter stringFromDate:date];
    return destDateString;
    
}

+ (BOOL)isSystemLangChinese
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
    NSString *currentLang = [languages objectAtIndex:0];
    
    if([currentLang compare:@"zh-Hans" options:NSCaseInsensitiveSearch]==NSOrderedSame || [currentLang compare:@"zh-Hant" options:NSCaseInsensitiveSearch]==NSOrderedSame)
    {
        return YES;
    }else
    {
        return NO;
    }
}

+(void)tapSound
{
    SystemSoundID soundTap;
    
    CFBundleRef CNbundle=CFBundleGetMainBundle();
    
    CFURLRef soundfileurl=CFBundleCopyResourceURL(CNbundle,(__bridge CFStringRef)@"tapSound",CFSTR("wav"),NULL);
    //创建system sound 对象
    AudioServicesCreateSystemSoundID(soundfileurl, &soundTap);
    AudioServicesPlaySystemSound(soundTap);
}

+(BOOL)isSystemVersionLessThan7{
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        return YES;
    } else {
        return NO;
    }
}

+(void)tapSound:(NSString *)name withType:(NSString *)type
{
    if ( [[[NSUserDefaults standardUserDefaults] objectForKey:@"SoundSwitch"] isEqualToString:@"off"]) {
        return;
    }
    
    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:name ofType:type];
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:soundFilePath ];
    [CommonUtility sharedCommonUtility].myAudioPlayer= [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
    [CommonUtility sharedCommonUtility].myAudioPlayer.volume = 1.0f;
    [[CommonUtility sharedCommonUtility].myAudioPlayer play];
    
}

+ (BOOL)myContainsStringFrom:(NSString*)str for:(NSString*)other {
    NSRange range = [str rangeOfString:other];
    return range.length != 0;
}

-(NSMutableDictionary *)sortIncomeByCategory:(NSMutableArray *)array
{
    NSMutableDictionary *incomeSortDic = [[NSMutableDictionary alloc] init];
    for (NSObject *oneItem in array) {
        if ([oneItem isKindOfClass:[itemObj class]]) {
            itemObj *item = (itemObj *)oneItem;
            if (item.itemType == 0) {
                continue;
            }
            NSString *cateName = item.itemCategory;
            double itemMoney = item.moneyAmount;
            
            NSNumber *savedMoney = [incomeSortDic objectForKey:cateName];
            if (!savedMoney)
            {
                [incomeSortDic setObject:[NSNumber numberWithDouble:itemMoney] forKey:cateName];
            }else
            {
                [incomeSortDic setObject:[NSNumber numberWithDouble:(itemMoney + [savedMoney doubleValue])] forKey:cateName];
            }
        }
    }
    return incomeSortDic;
    
}

-(NSMutableDictionary *)sortExpenseByCategory:(NSMutableArray *)array
{
    NSMutableDictionary *expenseSortDic = [[NSMutableDictionary alloc] init];
    for (NSObject *oneItem in array) {
        if ([oneItem isKindOfClass:[itemObj class]]) {
            itemObj *item = (itemObj *)oneItem;
            if (item.itemType == 1) {
                continue;
            }
            NSString *cateName = item.itemCategory;
            double itemMoney = item.moneyAmount;
            
            NSNumber *savedMoney = [expenseSortDic objectForKey:cateName];
            if (!savedMoney)
            {
                [expenseSortDic setObject:[NSNumber numberWithDouble:itemMoney] forKey:cateName];
            }else
            {
                [expenseSortDic setObject:[NSNumber numberWithDouble:(itemMoney + [savedMoney doubleValue])] forKey:cateName];
            }
        }
    }
    return expenseSortDic;
    
}

-(UIColor *)categoryColor:(NSString *)categoryName
{
    UIColor *color = [UIColor lightGrayColor];
    db = [[CommonUtility sharedCommonUtility] db];
    if (![db open]) {
        NSLog(@"addNewItem/Could not open db.");
        return color;
    }
    
    FMResultSet *rs = [db executeQuery:@"select * from CATEGORYINFO where category_name = ?",categoryName];
    while ([rs next]) {

        double color_R  = [rs doubleForColumn:@"color_R"];
        double color_G = [rs doubleForColumn:@"color_G"];
        double color_B = [rs doubleForColumn:@"color_B"];
        
        color = [UIColor colorWithRed:color_R/255.0f green:color_G/255.0f blue:color_B/255.0f alpha:1.0f ];
    }
    [db close];
    
    return color;
}


@end
