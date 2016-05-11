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
    [self configLastBackupView];
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
    UIView *content = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT/2 - 160, SCREEN_WIDTH, 160)];
    self.lastBackupView = content;
    
    UILabel *lastTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 80, 0, 160, 30)];
    lastTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f];
    lastTitleLabel.textAlignment = NSTextAlignmentCenter;
    [lastTitleLabel setText:@"上次备份时间及设备"];
    [lastTitleLabel setTextColor: TextColor];
    lastTitleLabel.backgroundColor = [UIColor clearColor];
    [content addSubview:lastTitleLabel];
    
    UIView *midLine = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-0.5, lastTitleLabel.frame.origin.y+lastTitleLabel.frame.size.height +10, 0.5, 105)];
    midLine.backgroundColor = [UIColor whiteColor];
    [content addSubview:midLine];
    
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(20, 159, SCREEN_WIDTH-40 , 0.5)];
    bottomLine.backgroundColor = [UIColor whiteColor];
    [content addSubview:bottomLine];
    
    UILabel *yearAndMonth = [[UILabel alloc] initWithFrame:CGRectMake(20, 35, SCREEN_WIDTH/2 - 40, 20)];
    yearAndMonth.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f];
    yearAndMonth.textAlignment = NSTextAlignmentCenter;
    [yearAndMonth setText:@"None-None"];
    [yearAndMonth setTextColor:  TextColor];
    yearAndMonth.backgroundColor = [UIColor clearColor];
    yearAndMonth.tag = 1;
    [content addSubview:yearAndMonth];
    
    UILabel *dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, yearAndMonth.frame.origin.y + yearAndMonth.frame.size.height, SCREEN_WIDTH/2 - 40, 50)];
    dayLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:40.0f];
    dayLabel.textAlignment = NSTextAlignmentCenter;
    [dayLabel setText:@"None"];
    [dayLabel setTextColor:  TextColor];
    dayLabel.backgroundColor = [UIColor clearColor];
    dayLabel.tag = 2;
    [content addSubview:dayLabel];
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, dayLabel.frame.origin.y + dayLabel.frame.size.height, SCREEN_WIDTH/2 - 40, 30)];
    timeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0f];
    timeLabel.textAlignment = NSTextAlignmentCenter;
    [timeLabel setText:@"None"];
    [timeLabel setTextColor:  TextColor];
    timeLabel.backgroundColor = [UIColor clearColor];
    timeLabel.tag = 3;
    [content addSubview:timeLabel];
    
    
    
    UILabel *deviceLabel = [[UILabel alloc] initWithFrame:CGRectMake(midLine.frame.origin.x +20, 55, SCREEN_WIDTH/2 - 40, 80)];
    deviceLabel.adjustsFontSizeToFitWidth = YES;
    deviceLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0f];
    deviceLabel.textAlignment = NSTextAlignmentCenter;
    [deviceLabel setText:@"None"];
    [deviceLabel setTextColor:  TextColor];
    deviceLabel.backgroundColor = [UIColor clearColor];
    deviceLabel.tag = 4;
    [content addSubview:deviceLabel];
    

    [self.view addSubview:content];
}

-(void)configOperaView
{
    UIView *content = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT/2, SCREEN_WIDTH, SCREEN_HEIGHT/2)];
    
    UIView *midLine = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-0.5, 30, 0.5, SCREEN_HEIGHT/2-60)];
    midLine.backgroundColor = [UIColor whiteColor];
    [content addSubview:midLine];
    
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
    hud.mode = MBProgressHUDModeAnnularDeterminate;
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

@end
