//
//  baseViewController.m
//  simpleFinance
//
//  Created by Eric Cao on 5/4/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "baseViewController.h"
#import "global.h"

@interface baseViewController ()
@property(nonatomic,strong) UIImageView *myBackImage;
@end

@implementation baseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *showModel =  [[NSUserDefaults standardUserDefaults] objectForKey:SHOWMODEL];
    if (!showModel) {
        self.myTextColor = normalColor;
    }else if ([showModel isEqualToString:@"上午"]) {
        self.myTextColor = TextColor0;
    }else if([showModel isEqualToString:@"下午"]) {
        self.myTextColor = TextColor1;
    }else if([showModel isEqualToString:@"夜间"]) {
        self.myTextColor = TextColor3;
    }

    [self registerThemeChangedNotification];
    NSLog(@"base view....");
    // Do any additional setup after loading the view from its nib.
    [self configUIAppearance];
}


- (void)registerThemeChangedNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                    selector:@selector(handleThemeChangedNotification:)
                                        name:ThemeChanged
                                      object:nil];
}

- (void)handleThemeChangedNotification:(NSNotification*)notification{

    [self configUIAppearance];
}

- (void)configUIAppearance{
    NSLog(@"base config ui ");
    NSString *showModel =  [[NSUserDefaults standardUserDefaults] objectForKey:SHOWMODEL];
    if ([showModel isEqualToString:@"上午"]) {
        self.myTextColor = TextColor0;
    }else if([showModel isEqualToString:@"下午"]) {
        self.myTextColor = TextColor1;
    }else if([showModel isEqualToString:@"夜间"]) {
        self.myTextColor = TextColor3;
    }
    NSString *backName;
    if (!showModel) {
        backName = @"上午.png";
    }else
    {
        backName  = [NSString stringWithFormat:@"%@.png",showModel];
    }
    
    if (!self.myBackImage)
    {
        self.myBackImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        [self.myBackImage setImage:[UIImage imageNamed:backName]];
        [self.view addSubview:self.myBackImage];
        [self.view sendSubviewToBack:self.myBackImage];
        [self.view setNeedsDisplay];
    }else
    {
        [self.myBackImage setImage:[UIImage imageNamed:backName]];
    }


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
