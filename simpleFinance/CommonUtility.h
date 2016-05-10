//
//  CommonUtility.h
//  ActiveWorld
//
//  Created by Eric Cao on 10/30/14.
//  Copyright (c) 2014 Eric Cao/Mady Kou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "global.h"
#import "LuckyLabel.h"

@interface CommonUtility : NSObject
{
    AVAudioPlayer *myAudioPlayer;
}

@property (nonatomic, strong) AVAudioPlayer *myAudioPlayer;
@property (nonatomic,strong) FMDatabase *db;
@property (nonatomic,strong) NSDateFormatter *dateFormatter;

+ (CommonUtility *)sharedCommonUtility;
+ (BOOL)isSystemLangChinese;
+ (void)tapSound;
+ (void)tapSound:(NSString *)name withType:(NSString *)type;
+ (BOOL)isSystemVersionLessThan7;
+ (BOOL)myContainsStringFrom:(NSString*)str forSubstring:(NSString*)other;
-(NSString *)todayDate;
-(NSString *)tomorrowDate;
-(NSString *)yesterdayDate;
-(NSString *)firstMonthDate;
-(NSString *)lastMonthDate;
-(NSString *)firstNextMonthDate;
//-(NSString *)oneDayBeforeDate:(NSString *)date;
- (NSString *) dateByAddingDays: (NSString *)srcDate andDaysToAdd:(NSInteger) daysToAdd;

-(NSMutableDictionary *)sortExpenseByCategory:(NSMutableArray *)array;
-(NSMutableDictionary *)sortIncomeByCategory:(NSMutableArray *)array;
-(UIColor *)categoryColor:(NSString *)categoryName;

-(NSDate *)dateFromString:(NSString *)pstrDate;
- (NSString *)stringFromDate:(NSDate *)date;

-(NSString *)weekEndDayOf:(NSDate *)date;
-(NSString *)weekStartDayOf:(NSDate *)date;
-(NSInteger)weekSequence:(NSDate *)date;


- (void)httpGetUrlNoToken:(NSString *)url
                   params:(NSDictionary *)paramsDict
                  success:(void(^)(NSDictionary *))success
                  failure:(void(^)(NSError *))failure;

-(void)fetchConstellation:(NSString *)constellation ForView:(LuckyLabel *)textLabel;
-(void)shimmerRegisterButton:(UIView *)registerButtonView ;
- (BOOL) validateEmail: (NSString *) candidate ;
@end
