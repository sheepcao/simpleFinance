//
//  exportViewController.m
//  simpleFinance
//
//  Created by Eric Cao on 5/23/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "exportViewController.h"
#import "CommonUtility.h"
#import "global.h"
#import "topBarView.h"
#import <MessageUI/MessageUI.h>
#import "CHCSVParser.h"
#import "MLIAPManager.h"

static NSString * const productId = @"sheepcao.simpleFinance.exportData";

@interface exportViewController ()<MFMailComposeViewControllerDelegate,MLIAPManagerDelegate>
@property (nonatomic,strong) FMDatabase *db;
@property (nonatomic,strong) topBarView *topBar;
@property (nonatomic, strong) UIView *tipView;
@property (nonatomic, strong) UIView *buyView;
@property (nonatomic, strong) UIView *operationView;

@property (nonatomic, strong) UIButton *myUploadButton;
@property (nonatomic, strong) UIButton *myDownloadButton;

@end

@implementation exportViewController
@synthesize db;


-(NSString *)dataFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:NSLocalizedString(@"数据导出-简簿.csv",nil) ];
}

-(NSString *)xlsFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:NSLocalizedString(@"数据导出-简簿.xls",nil) ];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self prepareData];
    [self configTopbar];
    
    [self configLastBackupView];
    [self configBuyView];
    [self configOperaView];

    NSString *exportBought = [[NSUserDefaults standardUserDefaults] objectForKey:EXPORTBUY];
    if (![exportBought isEqualToString:@"yes"]) {
        [self unBoughtView];
    }else
    {
        [self showBoughtView];
    }
}

-(void)showBoughtView
{
    [self.tipView setHidden:NO];
    [self.buyView setHidden:YES];
    self.myUploadButton.enabled = YES;
    self.myDownloadButton.enabled = YES;
    self.operationView.alpha = 1.0f;
}

-(void)unBoughtView
{
    [self.tipView setHidden:YES];
    [self.buyView setHidden:NO];
    self.myUploadButton.enabled = NO;
    self.myDownloadButton.enabled = NO;
    self.operationView.alpha = 0.6f;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareData
{
    self.flowData = [[NSMutableArray alloc] init];
    
    db = [[CommonUtility sharedCommonUtility] db];
    if (![db open]) {
        NSLog(@"mainVC/Could not open db.");
        return;
    }
    
    NSString *minDate = @"2016-05-01";
    NSString *maxDate = @"2016-12-01";
    
    FMResultSet *rs = [db executeQuery:@"select target_date from ITEMINFO order by target_date LIMIT 1"];
    while ([rs next]) {
        minDate = [rs stringForColumn:@"target_date"];
        NSArray *minArray = [minDate componentsSeparatedByString:@" "];
        minDate = minArray[0];
    }
    FMResultSet *rs2 = [db executeQuery:@"select target_date from ITEMINFO order by target_date desc LIMIT 1"];
    while ([rs2 next]) {
        maxDate = [rs2 stringForColumn:@"target_date"];
        NSArray *maxArray = [maxDate componentsSeparatedByString:@" "];
        maxDate = maxArray[0];
        maxDate = [[CommonUtility sharedCommonUtility] dateByAddingDays:maxDate andDaysToAdd:1];
    }
    

    FMResultSet *result = [db executeQuery:@"select * from ITEMINFO where strftime('%s', target_date) BETWEEN strftime('%s', ?) AND strftime('%s', ?)", minDate,maxDate];
    while ([result next]) {
        
        NSMutableDictionary *oneItemDict = [[NSMutableDictionary alloc] initWithCapacity:6];
        NSInteger type =[result intForColumn:@"item_type"];
        double money =  [result doubleForColumn:@"money"];
    
        [oneItemDict setObject:[result stringForColumn:@"item_category"] forKey:@"item_category"];
        [oneItemDict setObject:[result stringForColumn:@"item_description"] forKey:@"item_description"];
        if (type == 0) {
            [oneItemDict setObject:NSLocalizedString(@"支出",nil) forKey:@"item_type"];
        }else if (type == 1)
        {
            [oneItemDict setObject:NSLocalizedString(@"收入",nil) forKey:@"item_type"];
        }
        [oneItemDict setObject:[result stringForColumn:@"target_date"] forKey:@"target_date"];
        [oneItemDict setObject:[NSString stringWithFormat:@"%.2f",money] forKey:@"money"];
        [self.flowData addObject:oneItemDict];
    }
    
    [db close];

    
    CHCSVWriter *csvWriter=[[CHCSVWriter alloc]initForWritingToCSVFile:[self dataFilePath]];
    NSLog(@"%@",[self dataFilePath]);
    
    [csvWriter writeField:NSLocalizedString(@"日期",nil)];
    [csvWriter writeField:NSLocalizedString(@"收/支",nil)];
    [csvWriter writeField:NSLocalizedString(@"类别",nil)];
    [csvWriter writeField:NSLocalizedString(@"描述",nil)];
    [csvWriter writeField:NSLocalizedString(@"金额",nil)];

    [csvWriter finishLine];
    
    for(int i=0;i<[self.flowData count];i++)
    {
        [csvWriter writeField:[[self.flowData objectAtIndex:i] objectForKey:@"target_date"]];
        [csvWriter writeField:[[self.flowData objectAtIndex:i] objectForKey:@"item_type"]];
        [csvWriter writeField:[[self.flowData objectAtIndex:i] objectForKey:@"item_category"]];
        [csvWriter writeField:[[self.flowData objectAtIndex:i] objectForKey:@"item_description"]];
        [csvWriter writeField:[[self.flowData objectAtIndex:i] objectForKey:@"money"]];
        [csvWriter finishLine];
    }
    
    [csvWriter closeStream];
    
    [self exportToExcel];

    
}

- (void)exportToExcel
{

    NSString *header = @"<?xml version=\"1.0\"?><Workbook xmlns=\"urn:schemas-microsoft-com:office:spreadsheet\" xmlns:o=\"urn:schemas-microsoft-com:office:office\" xmlns:x=\"urn:schemas-microsoft-com:office:excel\" xmlns:ss=\"urn:schemas-microsoft-com:office:spreadsheet\" xmlns:html=\"http://www.w3.org/TR/REC-html40\"><Styles> <Style ss:ID=\"s21\"><Font x:Family=\"Swiss\" ss:Bold=\"1\" /></Style></Styles><Worksheet ss:Name=\"Sheet1\">";

    
    NSString *rowStart = @"<Row>";
    NSString *rowEnde = @"</Row>";
    
    NSString *stringStart = @"<Cell><Data ss:Type=\"String\">";
    NSString *boldStringStart = @"<Cell ss:StyleID=\"s21\"><Data ss:Type=\"String\">";

    NSString *stringEnde = @"</Data></Cell>";
    

    NSString *footer = @"</Table></Worksheet></Workbook>";
    
    NSString *xlsstring = @"";
    
    NSInteger numberOfRows =1;
    NSInteger numberOfCols = 5;
    numberOfRows = numberOfRows + self.flowData.count;
    
    NSString *colomnFormat = [NSString stringWithFormat:@"<Table ss:ExpandedColumnCount=\"%ld\" ss:ExpandedRowCount=\"%ld\" x:FullColumns=\"1\" x:FullRows=\"1\">",(long)numberOfCols,(long)numberOfRows];
    
    xlsstring = [NSString stringWithFormat:@"%@%@", header,colomnFormat];
    
     xlsstring = [xlsstring stringByAppendingFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", rowStart, boldStringStart,NSLocalizedString(@"日期",nil), stringEnde, boldStringStart,NSLocalizedString(@"收/支",nil), stringEnde, boldStringStart, NSLocalizedString(@"类别",nil), stringEnde, boldStringStart, NSLocalizedString(@"描述",nil), stringEnde, boldStringStart, NSLocalizedString(@"金额",nil), stringEnde,rowEnde];
    
    for (NSDictionary *form in self.flowData) {
        xlsstring = [xlsstring stringByAppendingFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", rowStart, stringStart, [form objectForKey:@"target_date"], stringEnde, stringStart, [form objectForKey:@"item_type"], stringEnde, stringStart, [form objectForKey:@"item_category"], stringEnde, stringStart, [form objectForKey:@"item_description"], stringEnde, stringStart, [form objectForKey:@"money"], stringEnde,rowEnde];
    }
    xlsstring = [xlsstring stringByAppendingFormat:@"%@", footer];
    
    [xlsstring writeToFile:[self xlsFilePath] atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

//-(void)testxls
//{
//    NSString *test = @"<?xml version=\"1.0\"?><Workbook xmlns=\"urn:schemas-microsoft-com:office:spreadsheet\" xmlns:o=\"urn:schemas-microsoft-com:office:office\" xmlns:x=\"urn:schemas-microsoft-com:office:excel\" xmlns:ss=\"urn:schemas-microsoft-com:office:spreadsheet\" xmlns:html=\"http://www.w3.org/TR/REC-html40\"><Worksheet ss:Name=\"Sheet1\"><Table ss:ExpandedColumnCount=\"2\" ss:ExpandedRowCount=\"2\" x:FullColumns=\"1\" x:FullRows=\"1\"><Row><Cell><Data ss:Type=\"String\">Name</Data></Cell><Cell><Data ss:Type=\"String\">Example</Data></Cell></Row><Row><Cell><Data ss:Type=\"String\">Value</Data></Cell><Cell><Data ss:Type=\"Number\">123</Data></Cell></Row></Table></Worksheet></Workbook>";
//    [test writeToFile:[self xlsFilePath] atomically:YES encoding:NSUTF16StringEncoding error:nil];
//
//}

-(void)closeVC
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)configTopbar
{
    self.topBar = [[topBarView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, topRowHeight + 5)];
    self.topBar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.topBar];
    [self.topBar.titleLabel  setText:NSLocalizedString(@"导出数据",nil)];
    
    
    UIButton * closeViewButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 32, 40, 40)];
    closeViewButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    closeViewButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [closeViewButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    closeViewButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    [closeViewButton setTitleColor:   normalColor forState:UIControlStateNormal];
    [closeViewButton addTarget:self action:@selector(closeVC) forControlEvents:UIControlEventTouchUpInside];
    closeViewButton.backgroundColor = [UIColor clearColor];
    [self.topBar addSubview:closeViewButton];
    
}

-(void)configLastBackupView
{
    UIView *content = [[UIView alloc] initWithFrame:CGRectMake(0, self.topBar.frame.size.height + (SCREEN_HEIGHT - 480) /3, SCREEN_WIDTH, 200)];
    self.tipView = content;
    
    UILabel *lastTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 150, 5, 300, 150)];
    lastTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:43.0f];
    lastTitleLabel.numberOfLines = 2;
    lastTitleLabel.adjustsFontSizeToFitWidth = YES;
    lastTitleLabel.textAlignment = NSTextAlignmentCenter;
    [lastTitleLabel setText:NSLocalizedString(@"请选择以下任意格式将数据发送到您的邮箱",nil)];

    [lastTitleLabel setTextColor: self.myTextColor];
    lastTitleLabel.backgroundColor = [UIColor clearColor];
    [content addSubview:lastTitleLabel];
    
    [self.view addSubview:content];
    
}

-(void)configBuyView
{
    UIView *content = [[UIView alloc] initWithFrame:CGRectMake(0, self.topBar.frame.size.height + (SCREEN_HEIGHT - 480) /3, SCREEN_WIDTH, 200)];
    self.buyView = content;
    
    UILabel * lastTitleLabel= [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 150, 5, 300, 100)];
    lastTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:50.0f];
    lastTitleLabel.adjustsFontSizeToFitWidth = YES;
    lastTitleLabel.textAlignment = NSTextAlignmentCenter;
    [lastTitleLabel setText:NSLocalizedString(@"6元购买永久使用数据导出功能",nil)];
    [lastTitleLabel setTextColor: self.myTextColor];
    lastTitleLabel.backgroundColor = [UIColor clearColor];
    [content addSubview:lastTitleLabel];
    
    UIButton *buyButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 40, lastTitleLabel.frame.origin.y + lastTitleLabel.frame.size.height + 10, 80, 40)];
    buyButton.layer.cornerRadius = 8;
    buyButton.layer.masksToBounds = NO;
    buyButton.layer.shadowColor = [UIColor blackColor].CGColor;
    buyButton.layer.shadowOpacity = 0.8;
    buyButton.layer.shadowRadius = 2;
    buyButton.layer.shadowOffset = CGSizeMake(1.2f, 2.2f);
    buyButton.layer.borderWidth = 0.75;
    buyButton.layer.borderColor = normalColor.CGColor;
    [buyButton setTitle:NSLocalizedString(@"购 买",nil) forState:UIControlStateNormal];
    [buyButton addTarget:self action:@selector(buyExport) forControlEvents:UIControlEventTouchUpInside];
    [content addSubview:buyButton];

    
    [self.view addSubview:content];
    
    [MLIAPManager sharedManager].delegate = self;

    
}

-(void)configOperaView
{
    UIView *content = [[UIView alloc] initWithFrame:CGRectMake(0, self.tipView.frame.origin.y + self.tipView.frame.size.height+5, SCREEN_WIDTH, SCREEN_HEIGHT/2)];
    self.operationView = content;
    
    UIButton *uploadButton = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH/6)/2,  content.frame.size.height/2 - (SCREEN_WIDTH/3)/0.83, SCREEN_WIDTH/3, (SCREEN_WIDTH/3)/0.83)];
    [uploadButton setImage:[UIImage imageNamed:@"backup"] forState:UIControlStateNormal];
    uploadButton.backgroundColor = [UIColor clearColor];
    [uploadButton addTarget:self action:@selector(csvExport) forControlEvents:UIControlEventTouchUpInside];
    [content addSubview:uploadButton];
    
    self.myUploadButton = uploadButton;
    
    UILabel *uploadText = [[UILabel alloc] initWithFrame:CGRectMake(uploadButton.frame.origin.x, uploadButton.frame.origin.y+uploadButton.frame.size.height + 2, uploadButton.frame.size.width, 20)];
    uploadText.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0f];
    [uploadText setTextColor:self.myTextColor];
    [uploadText setText:NSLocalizedString(@"导出CSV文件",nil)];
    uploadText.textAlignment = NSTextAlignmentCenter;
    [content addSubview:uploadText];
    
    UIButton *downLoadButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 +(SCREEN_WIDTH/6)/2, content.frame.size.height/2 - (SCREEN_WIDTH/3)/0.83, SCREEN_WIDTH/3, (SCREEN_WIDTH/3)/0.83)];
    [downLoadButton setImage:[UIImage imageNamed:@"download"] forState:UIControlStateNormal];
    downLoadButton.backgroundColor = [UIColor clearColor];
    [downLoadButton addTarget:self action:@selector(xlsExport) forControlEvents:UIControlEventTouchUpInside];
    [content addSubview:downLoadButton];
    self.myDownloadButton = downLoadButton;
    
    UILabel *downText = [[UILabel alloc] initWithFrame:CGRectMake(downLoadButton.frame.origin.x, downLoadButton.frame.origin.y+downLoadButton.frame.size.height + 2, downLoadButton.frame.size.width, 20)];
    downText.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0f];
    [downText setTextColor:self.myTextColor];
    [downText setText:NSLocalizedString(@"导出XLS文件",nil)];
    downText.textAlignment = NSTextAlignmentCenter;
    [content addSubview:downText];
    
    [self.view addSubview:content];
    
}

-(void)buyExport
{
    [[MLIAPManager sharedManager] requestProductWithId:productId];
}

-(void)csvExport
{
    
    
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    [picker.view setFrame:CGRectMake(0,20 , 320, self.view.frame.size.height-20)];
    picker.mailComposeDelegate = self;
    

    NSMutableString *emailBody = [NSMutableString string];
    [picker setSubject:NSLocalizedString(@"数据导出-简簿",nil) ];
    [emailBody appendString: NSLocalizedString(@"请查收附件中的数据文件",nil)];
    [picker setMessageBody:emailBody isHTML:NO];
    

    if (![[NSFileManager defaultManager] fileExistsAtPath:[self dataFilePath]]) {
        [[NSFileManager defaultManager] createFileAtPath:[self dataFilePath] contents:nil attributes:nil];
    }
    [picker addAttachmentData:[NSData dataWithContentsOfFile:[self dataFilePath]]
                     mimeType:@"text/csv"
                     fileName:NSLocalizedString(@"数据导出-简簿.csv",nil) ];

    [self presentViewController:picker animated:YES completion:nil];
}

-(void)xlsExport
{
    
    
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    [picker.view setFrame:CGRectMake(0,20 , 320, self.view.frame.size.height-20)];
    picker.mailComposeDelegate = self;
    
    
    NSMutableString *emailBody = [NSMutableString string];
    [picker setSubject:NSLocalizedString(@"数据导出-简簿",nil) ];
    [emailBody appendString: NSLocalizedString(@"将查收附件中的数据文件",nil)];
    [picker setMessageBody:emailBody isHTML:NO];
    
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self xlsFilePath]]) {
        [[NSFileManager defaultManager] createFileAtPath:[self xlsFilePath] contents:nil attributes:nil];
    }
    [picker addAttachmentData:[NSData dataWithContentsOfFile:[self xlsFilePath]]
                     mimeType:@"text/csv"
                     fileName:NSLocalizedString(@"数据导出-简簿.xls",nil) ];
    
    [self presentViewController:picker animated:YES completion:nil];
}


- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error

{
    
       [self  dismissViewControllerAnimated:YES completion:nil];
    
}



#pragma mark - **************** MLIAPManager Delegate

- (void)receiveProduct:(SKProduct *)product {
    
    if (product != nil) {
        //购买商品
        if (![[MLIAPManager sharedManager] purchaseProduct:product]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"失败",nil) message:NSLocalizedString(@"您禁止了应用内购买权限,请到设置中开启",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"关闭",nil) otherButtonTitles:nil, nil];
            [alert show];
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"失败",nil) message:NSLocalizedString(@"无法连接App store!",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"关闭",nil) otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)successfulPurchaseOfId:(NSString *)productId andReceipt:(NSData *)transactionReceipt {
    NSLog(@"购买成功");
    
//    NSString  *transactionReceiptString = [transactionReceipt base64EncodedStringWithOptions:0];
//    NSLog(@"transactionReceiptString:%@",transactionReceiptString);
    
    [self showBoughtView];
    [[NSUserDefaults standardUserDefaults] setObject:@"yes" forKey:EXPORTBUY];

    
    
//    if ([transactionReceiptString length] > 0) {
//        // 向自己的服务器验证购买凭证（此处应该考虑将凭证本地保存,对服务器有失败重发机制）
//        /**
//         服务器要做的事情:
//         接收ios端发过来的购买凭证。
//         判断凭证是否已经存在或验证过，然后存储该凭证。
//         将该凭证发送到苹果的服务器验证，并将验证结果返回给客户端。
//         如果需要，修改用户相应的会员权限
//         */
//    }
}

- (void)failedPurchaseWithError:(NSString *)errorDescripiton {
    NSLog(@"购买失败");
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"失败",nil) message:errorDescripiton delegate:self cancelButtonTitle:NSLocalizedString(@"关闭",nil) otherButtonTitles:nil, nil];
    [alert show];
}


@end
