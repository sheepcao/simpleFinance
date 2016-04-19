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



-(NSString *)firstMonthDate
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    
    NSDate *date = [NSDate date];
    
    NSDateComponents * currentDateComponents = [cal components: kCFCalendarUnitYear | NSCalendarUnitMonth fromDate: date];
    NSDate * startOfMonth = [cal dateFromComponents: currentDateComponents];
//    NSDate * endOfLastMonth = [startOfMonth dateByAddingTimeInterval: -1]; // One second before the start of this month

    return    [self stringFromDate:startOfMonth];
}
-(NSString *)lastMonthDate
{
    NSCalendar *cal = [NSCalendar currentCalendar];
        
    NSDate * plusOneMonthDate = [self dateByAddingMonths: 1];
    NSDateComponents * plusOneMonthDateComponents = [cal components: kCFCalendarUnitYear | NSCalendarUnitMonth fromDate: plusOneMonthDate];
    NSDate * endOfMonth = [cal dateFromComponents: plusOneMonthDateComponents]; // next month

    return [self stringFromDate:endOfMonth];
}
- (NSDate *) dateByAddingMonths: (NSInteger) monthsToAdd
{
    NSCalendar * calendar = [NSCalendar currentCalendar];
    NSDate *date = [NSDate date];

    NSDateComponents * months = [[NSDateComponents alloc] init];
    [months setMonth: monthsToAdd];
    
    return [calendar dateByAddingComponents: months toDate: date options: 0];
}
-(NSString *)tomorrowDate
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    
    NSDate *date = [NSDate date];
    NSDateComponents *comps = [cal components:(kCFCalendarUnitYear | NSCalendarUnitMonth | kCFCalendarUnitDay)
                                     fromDate:date];
    
    NSDate *today = [cal dateFromComponents:comps];
    NSDate *tomorrow = [today dateByAddingTimeInterval:(24*60*60)];
    
    return [self stringFromDate:tomorrow];
}
-(NSString *)yesterdayDate
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    
    NSDate *date = [NSDate date];
    NSDateComponents *comps = [cal components:(kCFCalendarUnitYear | NSCalendarUnitMonth | kCFCalendarUnitDay)
                                     fromDate:date];
    
    NSDate *today = [cal dateFromComponents:comps];
    NSDate *tomorrow = [today dateByAddingTimeInterval:(-24*60*60)];
    
    return [self stringFromDate:tomorrow];
}
- (NSString *)stringFromDate:(NSDate *)date{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
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


@end
