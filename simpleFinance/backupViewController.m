//
//  backupViewController.m
//  simpleFinance
//
//  Created by Eric Cao on 5/10/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "backupViewController.h"
#import "loginViewController.h"
#import "topBarView.h"
#import "global.h"
#import "CommonUtility.h"
#import "MBProgressHUD.h"
#import "AFHTTPRequestOperationManager.h"
#import "AFURLSessionManager.h"


@interface backupViewController ()
@property (nonatomic,strong)topBarView *topBar;
@property (nonatomic, strong) UIView *lastBackupView;
@property (nonatomic,strong) UIView *firstBackupView;

@end

@implementation backupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self configTopbar];
    [self configFirstBackupView];
    [self configLastBackupView];
    
    if ( !self.backupDay || [self.backupDay isKindOfClass:[NSNull class]] ) {
        [self.lastBackupView setHidden:YES];
        [self.firstBackupView setHidden:NO];
    }else
    {
        [self updateBackupInfoWithDate:self.backupDay andDevice:self.backupDevice];
        [self.lastBackupView setHidden:NO];
        [self.firstBackupView setHidden:YES];

    }
    [self configOperaView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)configTopbar
{
    self.topBar = [[topBarView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, topBarHeight)];
    self.topBar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.topBar];
    
    UIButton * closeViewButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 27, 60, 40)];
    closeViewButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    closeViewButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [closeViewButton setTitle:@"返回" forState:UIControlStateNormal];
    [closeViewButton setTitleColor:   [UIColor colorWithRed:76/255.0f green:101/255.0f blue:120/255.0f alpha:1.0f]forState:UIControlStateNormal];
    [closeViewButton addTarget:self action:@selector(closeVC) forControlEvents:UIControlEventTouchUpInside];
    closeViewButton.backgroundColor = [UIColor clearColor];
    [self.topBar addSubview:closeViewButton];
    
    UILabel *titileLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 50, 22, 100, 50)];
    [titileLabel setText:@"同步｜备份"];
    titileLabel.font = [UIFont fontWithName:@"SourceHanSansCN-Normal" size:titleSize];
    titileLabel.textAlignment = NSTextAlignmentCenter;
    [titileLabel setTextColor:[UIColor colorWithRed:76/255.0f green:101/255.0f blue:120/255.0f alpha:1.0f]];
    [self.topBar addSubview:titileLabel];

    
    UIButton *changeButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-65, 27, 60, 40)];
    changeButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    changeButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [changeButton setTitle:@"切换账号" forState:UIControlStateNormal];
    [changeButton setTitleColor:   [UIColor colorWithRed:76/255.0f green:101/255.0f blue:120/255.0f alpha:1.0f]forState:UIControlStateNormal];
    [changeButton addTarget:self action:@selector(changeAccount) forControlEvents:UIControlEventTouchUpInside];
    changeButton.backgroundColor = [UIColor clearColor];
    [self.topBar addSubview:changeButton];
    
}

-(void)changeAccount
{
    loginViewController *backupVC = [[loginViewController alloc] initWithNibName:@"loginViewController" bundle:nil];
    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
    [viewControllers removeObject:viewControllers.lastObject];
    [viewControllers addObject:backupVC];
    [self.navigationController setViewControllers:viewControllers animated:YES];

}

-(void)closeVC
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)configLastBackupView
{
    UIView *content = [[UIView alloc] initWithFrame:CGRectMake(0, self.topBar.frame.size.height + (SCREEN_HEIGHT - 480) /2, SCREEN_WIDTH, 200)];
    self.firstBackupView = content;
    
    UILabel *lastTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 120, 5, 240, 150)];
    lastTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:50.0f];
    lastTitleLabel.textAlignment = NSTextAlignmentCenter;
    [lastTitleLabel setText:@"首次备份"];
    [lastTitleLabel setTextColor: self.myTextColor];
    lastTitleLabel.backgroundColor = [UIColor clearColor];
    
    [content addSubview:lastTitleLabel];
    [self.view addSubview:content];
    
}

-(void)configFirstBackupView
{
    UIView *content = [[UIView alloc] initWithFrame:CGRectMake(0, self.topBar.frame.size.height + (SCREEN_HEIGHT - 480) /2, SCREEN_WIDTH, 200)];
    self.lastBackupView = content;
    
    UILabel *lastTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 120, 0, 240, 20)];
    lastTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f];
    lastTitleLabel.textAlignment = NSTextAlignmentCenter;
    [lastTitleLabel setText:@"上次备份时间及设备"];
    [lastTitleLabel setTextColor: self.myTextColor];
    lastTitleLabel.backgroundColor = [UIColor clearColor];
    [content addSubview:lastTitleLabel];
    

    
    UIView *midLine = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-0.5, lastTitleLabel.frame.origin.y+lastTitleLabel.frame.size.height +20, 0.5, 140)];
    midLine.backgroundColor = [UIColor whiteColor];
    [content addSubview:midLine];
    
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(20, content.frame.size.height - 1, SCREEN_WIDTH-40 , 0.5)];
    bottomLine.backgroundColor = [UIColor whiteColor];
    [content addSubview:bottomLine];
    
    UILabel *yearAndMonth = [[UILabel alloc] initWithFrame:CGRectMake(20, 60, SCREEN_WIDTH/2 - 40, 20)];
    yearAndMonth.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f];
    yearAndMonth.textAlignment = NSTextAlignmentCenter;
    [yearAndMonth setText:@"None-None"];
    
    [yearAndMonth setTextColor:  self.myTextColor];
    yearAndMonth.backgroundColor = [UIColor clearColor];
    yearAndMonth.tag = 1;
    [content addSubview:yearAndMonth];
    
    UILabel *dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, yearAndMonth.frame.origin.y + yearAndMonth.frame.size.height, SCREEN_WIDTH/2 - 40, 50)];
    dayLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:40.0f];
    dayLabel.textAlignment = NSTextAlignmentCenter;
    [dayLabel setText:@"None"];
    [dayLabel setTextColor:  self.myTextColor];
    dayLabel.backgroundColor = [UIColor clearColor];
    dayLabel.tag = 2;
    [content addSubview:dayLabel];
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, dayLabel.frame.origin.y + dayLabel.frame.size.height, SCREEN_WIDTH/2 - 40, 30)];
    timeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0f];
    timeLabel.textAlignment = NSTextAlignmentCenter;
    [timeLabel setText:@"None"];
    [timeLabel setTextColor:  self.myTextColor];
    timeLabel.backgroundColor = [UIColor clearColor];
    timeLabel.tag = 3;
    [content addSubview:timeLabel];
    
    
    
    UILabel *deviceLabel = [[UILabel alloc] initWithFrame:CGRectMake(midLine.frame.origin.x +20, 70, SCREEN_WIDTH/2 - 40, 80)];
    deviceLabel.adjustsFontSizeToFitWidth = YES;
    deviceLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0f];
    deviceLabel.textAlignment = NSTextAlignmentCenter;
    [deviceLabel setText:@"None"];
    [deviceLabel setTextColor:  self.myTextColor];
    deviceLabel.backgroundColor = [UIColor clearColor];
    deviceLabel.tag = 4;
    [content addSubview:deviceLabel];
    

    [self.view addSubview:content];
    
}

-(void)configOperaView
{
    UIView *content = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT/2, SCREEN_WIDTH, SCREEN_HEIGHT/2)];
    
//    UIView *midLine = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-0.5, 30, 0.5, SCREEN_HEIGHT/2-60)];
//    midLine.backgroundColor = [UIColor whiteColor];
//    [content addSubview:midLine];
    
    UIButton *uploadButton = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH/2 - 120)/2,  content.frame.size.height/2 - 60, 120, 120)];
    [uploadButton setTitle:@"备份至云端" forState:UIControlStateNormal];
    uploadButton.backgroundColor = [UIColor colorWithRed:.92 green:.65 blue:.29 alpha:.85];
    [uploadButton addTarget:self action:@selector(uploadData) forControlEvents:UIControlEventTouchUpInside];
    [content addSubview:uploadButton];
    
    UIButton *downLoadButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 +(SCREEN_WIDTH/2 - 120)/2, content.frame.size.height/2 - 60, 120, 120)];
    [downLoadButton setTitle:@"同步到本地" forState:UIControlStateNormal];
    downLoadButton.backgroundColor = [UIColor colorWithRed:.92 green:.65 blue:.29 alpha:.85];
    [downLoadButton addTarget:self action:@selector(downloadData) forControlEvents:UIControlEventTouchUpInside];
    [content addSubview:downLoadButton];
    
    [self.view addSubview:content];
    
}
-(void)updateBackupInfoWithDate:(NSString *)date andDevice:(NSString *)deviceName
{
    UILabel *yearMonth = (UILabel *)[self.lastBackupView viewWithTag:1];
    UILabel *dayLabel = (UILabel *)[self.lastBackupView viewWithTag:2];
    UILabel *timeLabel = (UILabel *)[self.lastBackupView viewWithTag:3];
    UILabel *deviceLabel = (UILabel *)[self.lastBackupView viewWithTag:4];
    
    NSArray *timeArray = [date componentsSeparatedByString:@" "];
    if (timeArray.count>0)
    {
        NSArray *yearMonthDay = [timeArray[0] componentsSeparatedByString:@"-"];
        if (yearMonthDay.count>2) {
            [yearMonth setText:[NSString stringWithFormat:@"%@ - %@",yearMonthDay[0],yearMonthDay[1]]];
            [dayLabel setText:[NSString stringWithFormat:@"%@",yearMonthDay[2]]];
        }
        
        NSArray *times = [timeArray[1] componentsSeparatedByString:@":"];
        if (times.count>2) {
            [timeLabel setText:[NSString stringWithFormat:@"%@ : %@ : %@ ",times[0],times[1],times[2]]];
        }
    }
    [deviceLabel setText:deviceName];

}


-(void)uploadData
{
    if ( !self.backupDay || [self.backupDay isKindOfClass:[NSNull class]] ) {
        [self uploadDB];
    }else
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"即将以当前设备的数据替换上次备份的数据",nil)  preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"确认",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self uploadDB];

        }];
        UIAlertAction* noAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消",nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
        [alert addAction:yesAction];
        [alert addAction:noAction];
        [self presentViewController:alert animated:YES completion:nil];
        
    }

}

-(void)uploadDB
{
    NSString *dbPath = [[CommonUtility sharedCommonUtility] dbPath];
    
    
    NSData *sqlData = [NSData dataWithContentsOfFile:dbPath];

    NSString * deviceName = [[UIDevice currentDevice] name];
    NSString * fileName = [NSString stringWithFormat:@"%@_JianBu.db",self.username];
    
    NSString *backupTime = [[CommonUtility sharedCommonUtility] timeNow];

    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"正在备份...";
    hud.dimBackground = YES;
    
    NSDictionary *parameters = @{@"tag": @"uploadSQLs",@"name":self.username,@"backup_device":deviceName,@"backupTime":backupTime};
    
    
    AFHTTPRequestOperationManager *manager2 = [AFHTTPRequestOperationManager manager];
    [manager2 setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    [manager2.requestSerializer setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    manager2.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [manager2.requestSerializer setTimeoutInterval:120];  //Time out after 120 seconds
    
    
    [manager2 POST:backupService  parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        if (sqlData) {
            [formData appendPartWithFileData:sqlData name:@"file" fileName:fileName mimeType:@"text/plain"];
        }
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success: %@ ***** %@", operation.responseString, responseObject);
        NSString *backupDay = [responseObject objectForKey:@"backup_day"];
        NSString *backupDevice = [responseObject objectForKey:@"backup_device"];
        
        [self updateBackupInfoWithDate:backupDay andDevice:backupDevice];
        [self.lastBackupView setHidden:NO];
        [self.firstBackupView setHidden:YES];
        
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"备份成功";
        [hud hide:YES afterDelay:1.5];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"Error";
        [hud hide:YES afterDelay:1.5];
        
        NSLog(@"Error: %@ ***** %@", operation.responseString, error);
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"%@\n备份失败，请重试",nil)  preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"确认",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:yesAction];
        [self presentViewController:alert animated:YES completion:nil];
    }];
}

-(void)downloadData
{
    if ( !self.backupDay || [self.backupDay isKindOfClass:[NSNull class]] )
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"您还未进行过备份，无法同步到本地。",nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"确认",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:yesAction];
        [self presentViewController:alert animated:YES completion:nil];

     
    }else
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"云端备份数据将覆盖本机当前数据，确认继续?",nil)  preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"确认",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self downloadURLFromServer];
        }];
        [alert addAction:yesAction];
        [self presentViewController:alert animated:YES completion:nil];

    }
}

-(void)downloadURLFromServer
{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"正在同步到本地...";
    hud.dimBackground = YES;
    hud.tag = 456;
    NSDictionary *parameters = @{@"tag": @"download",@"name":self.username};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [manager.requestSerializer setTimeoutInterval:120];  //Time out after 25 seconds
    
    
    [manager POST:backupService parameters:parameters success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        
        NSMutableArray *fullURLArray = [[NSMutableArray alloc] init];
        NSArray * URLArray = [responseObject objectForKey:@"files"];
        for (int i = 0; i <URLArray.count; i++) {
            NSString *oneURL = [NSString stringWithFormat:@"%@%@",backupPath,[responseObject objectForKey:@"files"][i]];
            [fullURLArray addObject:oneURL];
        }
        
        NSLog(@"URL URLArray: %@", fullURLArray);
        
        [self downloadFromURLs:fullURLArray];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
        NSLog(@"JSON ERROR: %@",  operation.responseString);
        
        hud.mode = MBProgressHUDModeText;
        
        hud.labelText = NSLocalizedString(@"同步失败，请稍后重试",nil);
        
        [hud hide:YES afterDelay:1.5];
        
        
    }];
}

-(void)downloadFromURLs:(NSMutableArray *)urlArray
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    [self downloadMulti:urlArray withManager:manager];
    
}
-(void)downloadMulti:(NSMutableArray *)urlArray withManager:(AFURLSessionManager *)manager
{
    
    if (urlArray.count == 0) {
        MBProgressHUD *hud = (MBProgressHUD *)[self.view viewWithTag:456];
        if(hud)
        {
            hud.mode = MBProgressHUDModeText;
            hud.labelText = NSLocalizedString(@"成功同步到本机",nil);
            [hud hide:YES afterDelay:1.2];

            [self performSelector:@selector(closeVC ) withObject:nil afterDelay:1.5];
        }
        return;
    }else
    {
        NSError *error;
        NSString *dirString = [[CommonUtility sharedCommonUtility] docsPath];

        NSData *dbFile = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:urlArray[0]]];
        
        NSString *fileName = [urlArray[0] componentsSeparatedByString:@"_"].lastObject;
        
        NSString *destPath = [NSString stringWithFormat:@"%@/%@",dirString,fileName];
        
        NSFileManager *fileManager =[NSFileManager defaultManager];
        if([fileManager fileExistsAtPath:destPath] == YES)
        {
            
            [[NSFileManager defaultManager] removeItemAtPath:destPath error:&error];
            NSLog(@"Error description-%@ \n", [error localizedDescription]);
            NSLog(@"Error reason-%@", [error localizedFailureReason]);
            
        }

        BOOL success = [dbFile writeToFile:destPath options:NSDataWritingAtomic error:&error];
        
        NSLog(@"destPath:%@ and success：%d for error:%@",destPath ,success,error);
        [urlArray removeObjectAtIndex:0];
        [self downloadMulti:urlArray withManager:manager];
    }
}


@end
