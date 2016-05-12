//
//  AppDelegate.m
//  simpleFinance
//
//  Created by Eric Cao on 4/7/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "AppDelegate.h"
#import "mainViewController.h"
#import "SideMenuViewController.h"
#import "MFSideMenuContainerViewController.h"
#import "CommonUtility.h"
#import "OpenShareHeader.h"

@interface AppDelegate ()
@property (nonatomic,strong) FMDatabase *db;
@end

@implementation AppDelegate
@synthesize db;


- (mainViewController *)demoController {
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    mainViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"mainViewController"];
    
    return vc;
}

- (UINavigationController *)navigationController {
    return [[UINavigationController alloc]
            initWithRootViewController:[self demoController]];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    NSString *autoSwitchString = [[NSUserDefaults standardUserDefaults] objectForKey:AUTOSWITCH];
    if (!autoSwitchString) {
        [[NSUserDefaults standardUserDefaults] setObject:@"on" forKey:AUTOSWITCH];
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    SideMenuViewController *rightMenuViewController = [[SideMenuViewController alloc] init];
    MFSideMenuContainerViewController *container = [MFSideMenuContainerViewController
                                                    containerWithCenterViewController:[self navigationController]
                                                    leftMenuViewController:nil
                                                    rightMenuViewController:rightMenuViewController];
    self.window.rootViewController = container;
    
    [self initDB];
    [self judgeTimeFrame];
    [self configShare];
    
    if ([CommonUtility isSystemLangChinese]) {
        [self loadLuckInfoFromServer];
    }else
    {
        NSLog(@"不是中文");
    }
    
    [self.window makeKeyAndVisible];
    

    
    return YES;
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    //第二步：添加回调
    if ([OpenShare handleOpenURL:url]) {
        return YES;
    }
    return YES;
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [self judgeTimeFrame];
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


-(void)initDB
{
    NSString*sortType = [[NSUserDefaults standardUserDefaults] objectForKey:@"sortType"];
    if (!sortType)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"category_id" forKey:@"sortType"];
    }
    
     db = [[CommonUtility sharedCommonUtility] db];
    
    if (![db open]) {
        NSLog(@"Could not open db.");
        return;
    }
    NSString *createItemTable = @"CREATE TABLE IF NOT EXISTS ITEMINFO (item_id INTEGER PRIMARY KEY AUTOINCREMENT,item_category TEXT,item_type INTEGER,item_description TEXT,money DECIMAL (15,2),target_date Date,create_time Date)";
    NSString *createCategoryTable = @"CREATE TABLE IF NOT EXISTS CATEGORYINFO (category_id INTEGER PRIMARY KEY AUTOINCREMENT,category_name TEXT,category_type INTEGER,color_R Double,color_G Double,color_B Double, is_deleted INTEGER DEFAULT 0)";
    NSString *createLuckTable = @"CREATE TABLE IF NOT EXISTS MONEYLUCK (luck_id INTEGER PRIMARY KEY AUTOINCREMENT,week_sequence INTEGER,luck_Cn TEXT,luck_En TEXT,start_date TEXT,content TEXT, constellation TEXT)";
    NSString *createColorTable = @"CREATE TABLE IF NOT EXISTS COLORINFO (color_id INTEGER PRIMARY KEY AUTOINCREMENT,color_R Double,color_G Double,color_B Double, used_count INTEGER)";

    
    [db executeUpdate:createItemTable];
    [db executeUpdate:createCategoryTable];
    [db executeUpdate:createLuckTable];
    [db executeUpdate:createColorTable];

    
    int categoryCount;
    NSString *selectCategoryCount = @"select count (*) from CATEGORYINFO";
    FMResultSet *rs = [db executeQuery:selectCategoryCount];
    if ([rs next]) {
        categoryCount = [rs intForColumnIndex:0];
    }
    if (categoryCount == 0) {
        [self insertDefaultCategoryToDB:db];
    }
    
    int colorCount;
    NSString *selectColorCount = @"select count (*) from COLORINFO";
    FMResultSet *rsColor = [db executeQuery:selectColorCount];
    if ([rsColor next]) {
        colorCount = [rsColor intForColumnIndex:0];
    }
    if (colorCount == 0) {
        [self insertDefaultColorToDB:db];
    }

    [db close];
}

-(void)judgeTimeFrame
{
    NSString *autoSwitchString = [[NSUserDefaults standardUserDefaults] objectForKey:AUTOSWITCH];
    if (![autoSwitchString isEqualToString:@"on"])
    {
        return;
    }
    
    NSCalendar *cal = [[NSCalendar alloc]
                       initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *date = [NSDate date];
    NSInteger hour = [cal component:NSCalendarUnitHour fromDate:date];
    
    if (hour>6 &&hour<11) {
        [[NSUserDefaults standardUserDefaults] setObject:@"早" forKey:MODEL];
    }else if(hour>=11 &&hour<14)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"午" forKey:MODEL];
    }else if(hour>=14 &&hour<=19)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"夕" forKey:MODEL];
    }else
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"夜" forKey:MODEL];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:ThemeChanged  object:nil];
    
    
}

-(void)loadLuckInfoFromServer
{
    NSDate *dateNow = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc]  initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components:NSCalendarUnitWeekday | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:dateNow];
    NSInteger dayofweek = [[gregorian components:NSCalendarUnitWeekday fromDate:dateNow] weekday];
    
    [components setDay:([components day] - ((dayofweek) - 1))];// for beginning of the week.
    
    NSDate *beginningOfWeek = [gregorian dateFromComponents:components];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.calendar = gregorian;
    [dateFormat setDateFormat:@"yyyy年MM月dd日"];
    NSString *dateString= [dateFormat stringFromDate:beginningOfWeek];
    
    if (![db open]) {
        NSLog(@"Could not open db.");
        return;
    }
    
    NSString *selectLuckExist = [NSString stringWithFormat:@"select * from MONEYLUCK where start_date = '%@'",dateString];
    
    FMResultSet *rs = [db executeQuery:selectLuckExist];
    if ([rs next]) {
//        NSString *luckString = [rs stringForColumn:@"content"];
//        [[NSUserDefaults standardUserDefaults] setObject:luckString forKey:@"luckString"];
        [db close];
    }else
    {
        [db close];
        
        NSDictionary *parameters = @{@"tag": @"fetch_luckinfo",@"start_date":dateString};
        
        [[CommonUtility sharedCommonUtility] httpGetUrlNoToken:constellationService params:parameters success:^(NSDictionary *success){
            
            if ([success objectForKey:@"success"] == 0) {
                return ;
            }
            
            NSArray *nameArray = [success objectForKey:@"name"];
            NSArray *contentArray = [success objectForKey:@"content"];
            NSString *startDate = [success objectForKey:@"start_date"][0];
            NSString *week = [success objectForKey:@"week"][0];
            
            
            NSLog(@"%@",startDate);
//            DLogObject(nameArray);
//            NSLog(@"%@",nameArray[0]);
//            NSLog(@"%@",contentArray[0]);
//            NSLog(@"%@",week);
            NSString *selectLuckExist = [NSString stringWithFormat:@"select * from MONEYLUCK where start_date = '%@'",dateString];
            if (![db open]) {
                NSLog(@"Could not open db.");
                return;
            }
            FMResultSet *rs = [db executeQuery:selectLuckExist];
            if ([rs next]) {
                [db close];
                return ;
            }

            for (int i = 0; i<nameArray.count; i++) {
                BOOL sql = [db executeUpdate:@"insert into MONEYLUCK (constellation,content,start_date,week_sequence) values (?,?,?,?)",nameArray[i],contentArray[i],startDate,week];
                if (!sql) {
                    NSLog(@"ERROR: %d - %@", db.lastErrorCode, db.lastErrorMessage);
                }
            }
            [db close];
            
        } failure:^(NSError * failure){
            NSLog(@"%@",failure);
        }];
    }
}

-(void)insertDefaultCategoryToDB:(FMDatabase *)database
{
    BOOL sql = [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('日常',0,71,53,58)"];
    [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('旅游',0,251,15,45)"];
    [database executeUpdate:@" insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('水电费',0,253,177,85)"];
    [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('阅读',0,250,47,82)"];
    [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('医疗',0,255,250,105)"];
    [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('交通',0,59,237,124)"];
    [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('工资',1,71,53,205)"];
    [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('奖金',1,95,115,218)"];
    [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('外快',1,142,162,29)"];
    [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('红包',1,68,120,119)"];
    
    if (!sql) {
        NSLog(@"CATEGORY ERROR: %d - %@", database.lastErrorCode, database.lastErrorMessage);
    }
    
}

-(void)insertDefaultColorToDB:(FMDatabase *)database
{
    BOOL sql = [database executeUpdate:@"insert into COLORINFO (color_R,color_G,color_B, used_count)values (122,50,121,0)"];
    [database executeUpdate:@"insert into COLORINFO (color_R,color_G,color_B, used_count)values (212,150,71,0)"];
    [database executeUpdate:@"insert into COLORINFO (color_R,color_G,color_B, used_count)values (222,53,11,0)"];
    [database executeUpdate:@"insert into COLORINFO (color_R,color_G,color_B, used_count)values (162,150,171,0)"];
    [database executeUpdate:@"insert into COLORINFO (color_R,color_G,color_B, used_count)values (192,31,171,0)"];
    [database executeUpdate:@"insert into COLORINFO (color_R,color_G,color_B, used_count)values (232,230,101,0)"];
    [database executeUpdate:@"insert into COLORINFO (color_R,color_G,color_B, used_count)values (50,200,181,0)"];
        if (!sql) {
        NSLog(@"COLOR ERROR: %d - %@", database.lastErrorCode, database.lastErrorMessage);
    }
    
}

-(void)configShare
{
    [OpenShare connectQQWithAppId:@"1104406509"];
    [OpenShare connectWeiboWithAppKey:@"3086417886"];
    [OpenShare connectWeixinWithAppId:@"wx060aa2d39d56bf11"];
}
@end
