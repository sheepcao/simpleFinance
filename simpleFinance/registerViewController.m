//
//  registerViewController.m
//  simpleFinance
//
//  Created by Eric Cao on 5/11/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "registerViewController.h"
#import "loginViewController.h"
#import "global.h"
#import "gradientButton.h"
#import "CommonUtility.h"
#import "MBProgressHUD.h"
#import "backupViewController.h"
#import "TermUseViewController.h"

@interface registerViewController ()<UITextFieldDelegate>
@property (nonatomic,strong) UIView *contentView;
@property (nonatomic,strong) UITextField *userField;
@property (nonatomic,strong) UITextField *pswdField;
@end

@implementation registerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    
    
    [self configInputArea];
    UIButton * closeViewButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 27, 60, 40)];
    closeViewButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    closeViewButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [closeViewButton setTitle:@"返回" forState:UIControlStateNormal];
    [closeViewButton setTitleColor:   [UIColor colorWithRed:76/255.0f green:101/255.0f blue:120/255.0f alpha:1.0f]forState:UIControlStateNormal];
    [closeViewButton addTarget:self action:@selector(closeVC) forControlEvents:UIControlEventTouchUpInside];
    closeViewButton.backgroundColor = [UIColor clearColor];
    [self.view addSubview:closeViewButton];
}
-(void)closeVC
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)configInputArea
{
    UIView *content = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    content.backgroundColor = [UIColor clearColor];
    [self.view addSubview:content];
    
    UIImageView *logoView =[[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/3, SCREEN_HEIGHT/5.5, SCREEN_WIDTH/3, SCREEN_WIDTH/3)];
    [logoView setImage:[UIImage imageNamed: @"logo.png"]];
    [content addSubview:logoView];
    self.contentView = content;
    
    
    UITextField *usernameField = [[UITextField alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/8, logoView.frame.origin.y + logoView.frame.size.height + 30, SCREEN_WIDTH*3/4, SCREEN_WIDTH/8)];
    usernameField.attributedPlaceholder =
    [[NSAttributedString alloc] initWithString:@"邮箱（用户名）"
                                    attributes:@{
                                                 NSForegroundColorAttributeName: [UIColor colorWithRed:0.41 green:0.41 blue:0.41 alpha:0.9],
                                                 NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:SCREEN_WIDTH/22]
                                                 }
     ];
    usernameField.textAlignment = NSTextAlignmentCenter;
    usernameField.returnKeyType = UIReturnKeyDone;
    usernameField.delegate = self;
    usernameField.tintColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.9];
    usernameField.font =  [UIFont fontWithName:@"HelveticaNeue-Light" size:SCREEN_WIDTH/21];
    usernameField.textColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.9];
    [usernameField.layer setCornerRadius:usernameField.frame.size.height/2];
    [usernameField setBackgroundColor:[UIColor whiteColor]];
    [usernameField.layer setBorderColor:[UIColor grayColor].CGColor];
    [usernameField.layer setBorderWidth:0.4];
    [content addSubview:usernameField];
    self.userField = usernameField;
    
    UILabel *hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 80 , usernameField.frame.origin.y + usernameField.frame.size.height + 2, 160, 20)];
    hintLabel.textAlignment = NSTextAlignmentCenter;
    hintLabel.font =  [UIFont fontWithName:@"HelveticaNeue-Medium" size:12.5f];
    hintLabel.textColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:0.9];
    [hintLabel setText:@"*重要 : 用于登录及密码找回"];
    [content addSubview:hintLabel];
    
    UIView *leftGradient = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/9, hintLabel.frame.origin.y + hintLabel.frame.size.height/2-1, SCREEN_WIDTH/2 - SCREEN_WIDTH/9 - hintLabel.frame.size.width/2, 2)];
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = leftGradient.bounds;
    gradientLayer.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithWhite:0.96 alpha:0.0f].CGColor, (id)[UIColor colorWithWhite:0.96 alpha:1.0f].CGColor, nil];
    gradientLayer.startPoint = CGPointMake(0.0f, 0.5f);
    gradientLayer.endPoint = CGPointMake(1.0f, 0.5f);
    gradientLayer.cornerRadius = leftGradient.frame.size.height/2;
    leftGradient.layer.mask = gradientLayer;
    [leftGradient.layer insertSublayer:gradientLayer atIndex:0];
    
    UIView *rightGradient = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 + hintLabel.frame.size.width/2, hintLabel.frame.origin.y + hintLabel.frame.size.height/2-1, leftGradient.frame.size.width, 2)];
    CAGradientLayer *gradientLayerR = [CAGradientLayer layer];
    gradientLayerR.frame = rightGradient.bounds;
    gradientLayerR.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithWhite:0.96 alpha:1.0f].CGColor, (id)[UIColor colorWithWhite:0.96 alpha:0.0f].CGColor, nil];
    gradientLayerR.startPoint = CGPointMake(0.0f, 0.5f);
    gradientLayerR.endPoint = CGPointMake(1.0f, 0.5f);
    gradientLayerR.cornerRadius = rightGradient.frame.size.height/2;
    rightGradient.layer.mask = gradientLayerR;
    [rightGradient.layer insertSublayer:gradientLayerR atIndex:0];
    
    [content addSubview:leftGradient];
    [content addSubview:rightGradient];
    


    UITextField *passwordField = [[UITextField alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/8, usernameField.frame.origin.y + usernameField.frame.size.height + 30, SCREEN_WIDTH*3/4, SCREEN_WIDTH/8)];
    passwordField.attributedPlaceholder =
    [[NSAttributedString alloc] initWithString:@"设置密码"
                                    attributes:@{
                                                 NSForegroundColorAttributeName: [UIColor colorWithRed:0.41 green:0.41 blue:0.41 alpha:0.9],
                                                 NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:SCREEN_WIDTH/19]
                                                 }
     ];
    passwordField.textAlignment = NSTextAlignmentCenter;
    passwordField.returnKeyType = UIReturnKeyDone;
    passwordField.delegate = self;
    passwordField.tintColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.9];
    passwordField.font =  [UIFont fontWithName:@"HelveticaNeue-Light" size:SCREEN_WIDTH/21];
    passwordField.textColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.9];
    [passwordField.layer setCornerRadius:passwordField.frame.size.height/2];
    [passwordField setBackgroundColor:[UIColor whiteColor]];
    [passwordField.layer setBorderColor:[UIColor grayColor].CGColor];
    [passwordField.layer setBorderWidth:0.4];
    [content addSubview:passwordField];
    passwordField.secureTextEntry = YES;
    self.pswdField = passwordField;
    
    gradientButton *loginButton = [[gradientButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/8, passwordField.frame.origin.y + passwordField.frame.size.height + 30, SCREEN_WIDTH*3/4, SCREEN_WIDTH/7.5)];
    loginButton.titleLabel.font =  [UIFont fontWithName:@"HelveticaNeue-Light" size:23.0f];
    [loginButton setTitle:@"注  册" forState:UIControlStateNormal];
    [content addSubview:loginButton];
    [loginButton addTarget:self action:@selector(userRegister) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *termsLabel = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 100 , SCREEN_HEIGHT - 40, 200, 20)];
    termsLabel.titleLabel.textAlignment = NSTextAlignmentCenter;
    termsLabel.titleLabel.numberOfLines = 2;
    termsLabel.titleLabel.font =  [UIFont fontWithName:@"SourceHanSansCN-Normal" size:11.0f];
    termsLabel.titleLabel.textColor = [UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:0.88];
    [termsLabel setTitle:@"点击提交，您将同意并遵守简簿的用户使用条款。点击阅读 >" forState:UIControlStateNormal];
    [termsLabel addTarget: self action:@selector(userTerms) forControlEvents:UIControlEventTouchUpInside];
    [content addSubview:termsLabel];
    
    [[CommonUtility sharedCommonUtility] shimmerRegisterButton:loginButton];
    
}

-(void)userTerms
{
    TermUseViewController *termsVC = [[TermUseViewController alloc] initWithNibName:@"TermUseViewController" bundle:nil];
    [self.navigationController pushViewController:termsVC animated:YES];
}

-(void)keyboardWasShown:(NSNotification*)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.25f animations:^{
        [self.contentView setFrame:CGRectMake(0,0 - (keyboardSize.height-(SCREEN_HEIGHT - self.pswdField.frame.origin.y - SCREEN_WIDTH*2/7-35)) , self.contentView.frame.size.width, self.contentView.frame.size.height)];
    }];
    
}
-(void)dismissKeyboard {
    if ([self.userField isFirstResponder]) {
        [self textFieldShouldReturn:self.userField];
    }else if([self.pswdField isFirstResponder])
    {
        [self textFieldShouldReturn:self.pswdField];
    }
}

#pragma mark UITextField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [UIView animateWithDuration:0.25f animations:^{
        [self.contentView setFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
    }];
    [textField resignFirstResponder];
    
    BOOL isValidEmail = [[CommonUtility sharedCommonUtility] validateEmail:self.userField.text];
    if (!isValidEmail) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.animationType = MBProgressHUDAnimationZoom;
        hud.labelFont = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"请输入正确的邮箱格式";
        [hud hide:YES afterDelay:1.5];
        [self.userField becomeFirstResponder];
    }
    
    return NO;
}

-(void)userRegister
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.dimBackground = YES;

    NSDictionary *parameters = @{@"tag": @"register",@"name":self.userField.text,@"password":self.pswdField.text};
    
    [[CommonUtility sharedCommonUtility] httpGetUrlNoToken:backupService params:parameters success:^(NSDictionary *success){
        //
        hud.mode = MBProgressHUDModeText;
        hud.labelText = NSLocalizedString(@"注册成功",nil);
        [hud hide:YES afterDelay:2.0];

        NSString *name = [success objectForKey:@"username"];
        
        [[NSUserDefaults standardUserDefaults] setObject:name forKey:DEFAULT_USER];
        
        [self performSelector:@selector(goBackupFor:) withObject:name afterDelay:0.21];

        NSLog(@"%@",success);
        
    } failure:^(NSError * failure){
        NSLog(@"%@",failure);
        hud.mode = MBProgressHUDModeText;
        [hud hide:YES afterDelay:2.0];
        
        NSString *error = [NSString stringWithFormat:@"Error: ***** %@", failure];
        if ([CommonUtility myContainsStringFrom:error forSubstring:@"416"]) {
            hud.labelText = NSLocalizedString(@"您输入的注册邮箱已存在，换一个吧",nil);
        }else
        {
            hud.labelText = NSLocalizedString(@"注册失败，请重试",nil);
        }
    }];
}

-(void)goBackupFor:(NSString *)name
{
    backupViewController *backupVC = [[backupViewController alloc] initWithNibName:@"backupViewController" bundle:nil];
    backupVC.username = name;
    
    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
    if ([viewControllers.lastObject isKindOfClass:[registerViewController class]]) {
        [viewControllers removeObject:viewControllers.lastObject];
    }
    if ([viewControllers.lastObject isKindOfClass:[loginViewController class]]) {
        [viewControllers removeObject:viewControllers.lastObject];
    }
    [viewControllers addObject:backupVC];
    [self.navigationController setViewControllers:viewControllers animated:YES];
    
}
@end
