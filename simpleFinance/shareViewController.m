//
//  ViewController.m
//  XHShareDemo
//
//  Created by craneteng on 16/3/31.
//  Copyright © 2016年 craneteng. All rights reserved.
//

#import "shareViewController.h"
#import "XHShareView.h"
#import "OpenShareHeader.h"
#import <MessageUI/MessageUI.h>
#import "topBarView.h"
#import "global.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@interface shareViewController ()<XHShareViewDelegate,MFMessageComposeViewControllerDelegate>
@property (nonatomic,strong) topBarView *topBar;
@end

@implementation shareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGSize size = [[UIScreen mainScreen] bounds].size;
    CGFloat viewHight = 120;
    
    [self configTopbar];
    
    UILabel *sao = [[UILabel alloc]init];
    sao.textColor = self.myTextColor;
    sao.frame = CGRectMake((size.width - 100) * 0.5, topBarHeight+20, 100,50);
    sao.textAlignment = NSTextAlignmentCenter;
    sao.text = @"扫码下载";
    [self.view addSubview:sao];
    
    UIImageView *QRcode = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"logo.png"]];
    QRcode.frame = CGRectMake(size.width * 0.2, sao.frame.size.height + sao.frame.origin.y + 5,size.width * 0.6 , size.width * 0.6);
    [self.view addSubview:QRcode];
    

    
    XHShareView *shareView = [[XHShareView alloc] initWithFrame:CGRectMake(size.width * 0.1 , size.height - viewHight - 30 - (SCREEN_WIDTH - 320), size.width * 0.8, viewHight)];
    shareView.delegate = self;
    [self.view addSubview:shareView];
    
    UILabel *share = [[UILabel alloc]init];
    share.textColor = self.myTextColor;
    share.frame = CGRectMake((size.width - 70) * 0.5,shareView.frame.origin.y - 50 , 70,40);
    share.text = @"或分享至";
    share.textAlignment = NSTextAlignmentCenter;

    [self.view addSubview:share];
}

-(void)closeVC
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)configTopbar
{
    self.topBar = [[topBarView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, topBarHeight)];
    self.topBar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.topBar];
    
    
    UILabel *titileLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 50, 22, 100, 50)];
    [titileLabel setText:@"邀请好友"];
    titileLabel.font = [UIFont fontWithName:@"SourceHanSansCN-Normal" size:titleSize];
    titileLabel.textAlignment = NSTextAlignmentCenter;
    [titileLabel setTextColor:[UIColor colorWithRed:76/255.0f green:101/255.0f blue:120/255.0f alpha:1.0f]];
    [self.topBar addSubview:titileLabel];
    
    
    UIButton *changeButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-65, 30, 60, 40)];
    changeButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    changeButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [changeButton setTitle:@"取消" forState:UIControlStateNormal];
    [changeButton setTitleColor:   [UIColor colorWithRed:76/255.0f green:101/255.0f blue:120/255.0f alpha:1.0f]forState:UIControlStateNormal];
    [changeButton addTarget:self action:@selector(closeVC) forControlEvents:UIControlEventTouchUpInside];
    changeButton.backgroundColor = [UIColor clearColor];
    [self.topBar addSubview:changeButton];
    
}

#pragma mark -- XHShareViewDelegate
- (void) XHDidClickShareBtn:(ShareBtn)type{
    switch (type) {
        case SharePyQuan:{
            // 分享到朋友圈
            [self pyqClick];
            break;
        }
        case ShareWeix:{
            [self wxFriendClick];
            // 发给微信好友
            break;
        }case ShareMsg:{
            // 点击了短信
            [FBSDKShareDialog showFromViewController:self
                                         withContent:[self fbClick]
                                            delegate:nil];
            break;
        }case ShareSina:{
            // 分享到微博
            [self sinaWBClick];
            break;
        }case ShareQQ:{
            // 发给QQ好友
            [self qqFriend];
            break;
        }case ShareQzone:{
            // 分享到QQ空间
            [self qzone];
            break;
        }default:{
            NSLog(@"默认");
            break;
        }
    }
}

#pragma mark - 配置分享信息
- (OSMessage *)shareMessage {
    OSMessage *message = [[OSMessage alloc] init];
//    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
//    fmt.dateFormat = @"yyyy年MM月dd日HH时mm分ss秒";
//    NSString *now = [fmt stringFromDate:[NSDate date]];
    message.title = [NSString stringWithFormat:@"简簿－简明财务,跃然于簿"];
    message.image = [UIImage imageNamed:@"logo"];
    // 缩略图
    message.thumbnail = [UIImage imageNamed:@"switchChart.png"];
    message.desc = [NSString stringWithFormat:@"简单一点,一目了然。\n财务详情,了然于心"];
    message.link=@"http://www.baidu.com";
    return message;
}

#pragma mark - 分享到微博
- (void)sinaWBClick {
    OSMessage *message = [self shareMessage];
    [OpenShare shareToWeibo:message Success:^(OSMessage *message) {
        NSLog(@"分享到sina微博成功:\%@",message);
    } Fail:^(OSMessage *message, NSError *error) {
        NSLog(@"分享到sina微博失败:\%@\n%@",message,error);
    }];
}

#pragma mark - 分享给QQ好友
- (void)qqFriend {
    OSMessage *message = [self shareMessage];
    [OpenShare shareToQQFriends:message Success:^(OSMessage *message) {
        NSLog(@"分享到QQ好友成功:%@",message);
    } Fail:^(OSMessage *message, NSError *error) {
        NSLog(@"分享到QQ好友失败:%@\n%@",message,error);
    }];
    
}

#pragma mark - 分享到QQ空间
- (void)qzone{
    OSMessage *message = [self shareMessage];
    [OpenShare shareToQQZone:message Success:^(OSMessage *message) {
        NSLog(@"分享到QQ空间成功:%@",message);
    } Fail:^(OSMessage *message, NSError *error) {
        NSLog(@"分享到QQ空间失败:%@\n%@",message,error);
    }];
}

#pragma mark - 分享给微信好友
- (void)wxFriendClick{
    OSMessage *message = [self shareMessage];
    [OpenShare shareToWeixinSession:message Success:^(OSMessage *message) {
        NSLog(@"微信分享到会话成功：\n%@",message);
    } Fail:^(OSMessage *message, NSError *error) {
        NSLog(@"微信分享到会话失败：\n%@\n%@",error,message);
    }];
}

#pragma mark - 分享到朋友圈
- (void)pyqClick{
    OSMessage *message = [self shareMessage];
    [OpenShare shareToWeixinTimeline:message Success:^(OSMessage *message) {
        NSLog(@"微信分享到朋友圈成功：\n%@",message);
    } Fail:^(OSMessage *message, NSError *error) {
        NSLog(@"微信分享到朋友圈失败：\n%@\n%@",error,message);
    }];
}


#pragma nark --fb
-(FBSDKShareLinkContent *)fbClick
{
    
//    OSMessage *message = [self shareMessage];

    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentURL = [NSURL URLWithString:REVIEW_URL];
//    content.contentTitle = message.title;
//    content.contentDescription = message.desc;
//    content.imageURL = [[NSBundle mainBundle]
//                        URLForResource: @"logo" withExtension:@"png"];
    return content;

}

- (FBSDKShareDialog *)getShareDialogWithContent
{
    FBSDKShareDialog *shareDialog = [[FBSDKShareDialog alloc] init];
    shareDialog.shareContent = [self fbClick];
    return shareDialog;
}

#pragma mark - 发送短信
- (void)sendMessage{
    if( [MFMessageComposeViewController canSendText] ){
        MFMessageComposeViewController * controller = [[MFMessageComposeViewController alloc]init]; //autorelease];
        // 短信的接收人
        controller.recipients = nil;//[NSArray arrayWithObject:@""]
        controller.body = @"简簿－简明财务,跃然于簿\n简单一点,一目了然。\n财务详情,了然于心\n简簿App下载地址:www.baidu.com";
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:nil];
    }else{
        NSLog(@"您的设备没有发送短信功能");
    }
}

#pragma mark -- MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    [controller dismissViewControllerAnimated:NO completion:nil];
    
    switch (result) {
        case MessageComposeResultCancelled:
            NSLog(@"发送取消");
            break;
        case MessageComposeResultFailed:// send failed
            NSLog(@"发送失败");
            break;
        case MessageComposeResultSent:
            NSLog(@"发送成功");
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
