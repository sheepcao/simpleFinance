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

@interface CommonUtility : NSObject
{
    AVAudioPlayer *myAudioPlayer;
}

@property (nonatomic, strong) AVAudioPlayer *myAudioPlayer;
@property (nonatomic,strong) FMDatabase *db;

+ (CommonUtility *)sharedCommonUtility;
+ (BOOL)isSystemLangChinese;
+ (void)tapSound;
+ (void)tapSound:(NSString *)name withType:(NSString *)type;
+ (BOOL)isSystemVersionLessThan7;
+ (BOOL)myContainsStringFrom:(NSString*)str for:(NSString*)other;
-(NSString *)tomorrowDate;
-(NSString *)yesterdayDate;
-(NSString *)firstMonthDate;
-(NSString *)lastMonthDate;

-(NSMutableDictionary *)sortExpenseByCategory:(NSMutableArray *)array;
-(NSMutableDictionary *)sortIncomeByCategory:(NSMutableArray *)array;
-(UIColor *)categoryColor:(NSString *)categoryName;
@end
