//
//  SideMenuViewController.m
//  simpleFinance
//
//  Created by Eric Cao on 4/8/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "SideMenuViewController.h"
#import "global.h"
#import "MFSideMenu.h"
#import "calendarViewController.h"
#import "categoryManagementViewController.h"
#import "mainViewController.h"
#import "monthListViewController.h"
#import "loginViewController.h"
#import "backupViewController.h"
#import "aboutViewController.h"

@interface SideMenuViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) NSArray *menuArray;
@property(nonatomic,strong) UIImageView *myBackImage;

@end

@implementation SideMenuViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.menuArray = @[NSLocalizedString(@"同 步 | 备 份",nil),NSLocalizedString(@"分类管理",nil),NSLocalizedString(@"帐目流水",nil),NSLocalizedString(@"帐目日历",nil),NSLocalizedString(@"显示模式",nil),NSLocalizedString(@"关于简簿",nil)];
    
    UITableView *menuTable = [[UITableView alloc] initWithFrame:CGRectMake(0, (SCREEN_HEIGHT-6*(SCREEN_WIDTH/5.5))*2/3, SCREEN_WIDTH*2/3, 6*(SCREEN_WIDTH/5.5))];
    menuTable.delegate = self;
    menuTable.dataSource = self;
    menuTable.scrollEnabled = NO;
    menuTable.backgroundColor = [UIColor clearColor];
    menuTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:menuTable];
    self.myMenuTable = menuTable;
    
//    [self configUIAppearance];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"SideMenu"];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"SideMenu"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    NSLog(@"sidebar config ui ");
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
        backName = @"上午1.png";
    }else
    {
        backName  = [NSString stringWithFormat:@"%@1.png",showModel];
    }
    
    if (!self.myBackImage)
    {
        self.myBackImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH*2/3, SCREEN_HEIGHT)];
        [self.myBackImage setImage:[UIImage imageNamed:backName]];
        [self.view addSubview:self.myBackImage];
        [self.view sendSubviewToBack:self.myBackImage];
        [self.view setNeedsDisplay];
    }else
    {
        [self.myBackImage setImage:[UIImage imageNamed:backName]];
    }

    [self.myMenuTable reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SCREEN_WIDTH/5.5;

}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    return [NSString stringWithFormat:@"Section %d", section];
//}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.menuArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        
    }


    UIFontDescriptor *attributeFontDescriptorFirstPart = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                                          @{UIFontDescriptorFamilyAttribute: @"Source Han Sans CN",
                                                            UIFontDescriptorNameAttribute:@"SourceHanSansCN-Normal",
                                                            UIFontDescriptorSizeAttribute: [NSNumber numberWithFloat: SCREEN_WIDTH/20]
                                                            }];
//    cell.textLabel.text = [NSString stringWithFormat:@"%@", self.menuArray[indexPath.row]];
//    cell.textLabel.textColor = self.myTextColor;
//    [cell.textLabel setFont:[UIFont fontWithDescriptor:attributeFontDescriptorFirstPart size:0.0f]];
//    cell.textLabel.textAlignment = NSTextAlignmentCenter;

    UILabel *cellTitle = [[UILabel alloc] initWithFrame:CGRectMake(tableView.frame.size.width/4, 0, tableView.frame.size.width*3/4, cell.frame.size.height)];
    cellTitle.textColor = self.myTextColor;
    [cellTitle setFont:[UIFont fontWithDescriptor:attributeFontDescriptorFirstPart size:0.0f]];
    cellTitle.textAlignment = NSTextAlignmentLeft;
    cellTitle.text = [NSString stringWithFormat:@"%@", self.menuArray[indexPath.row]];
    [cell addSubview:cellTitle];

    return cell;
}


#pragma mark -
#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    tableView.userInteractionEnabled = NO;

    if (indexPath.row ==0) {

        loginViewController *loginVC = [[loginViewController alloc] initWithNibName:@"loginViewController" bundle:nil];
        UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
        NSMutableArray *temp = [NSMutableArray arrayWithArray:navigationController.viewControllers];
        [temp addObject:loginVC];
        navigationController.viewControllers = temp;
        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
        
    }else if (indexPath.row ==1) {
        categoryManagementViewController *trendVC = [[categoryManagementViewController alloc] initWithNibName:@"categoryManagementViewController" bundle:nil];
        UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
        NSMutableArray *temp = [NSMutableArray arrayWithArray:navigationController.viewControllers];
        [temp addObject:trendVC];
        navigationController.viewControllers = temp;
        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];

    }else if(indexPath.row ==2)
    {
        monthListViewController *monthListVC = [[monthListViewController alloc] initWithNibName:@"monthListViewController" bundle:nil];
        UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
        NSMutableArray *temp = [NSMutableArray arrayWithArray:navigationController.viewControllers];
        [temp addObject:monthListVC];
        navigationController.viewControllers = temp;
        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
        
    }else if (indexPath.row == 3) {
        calendarViewController *trendVC = [[calendarViewController alloc] initWithNibName:@"calendarViewController" bundle:nil];
        UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
        NSMutableArray *temp = [NSMutableArray arrayWithArray:navigationController.viewControllers];
        [temp addObject:trendVC];
        navigationController.viewControllers = temp;
        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];

    }else if(indexPath.row ==4)
    {
        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
        UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
        NSMutableArray *temp = [NSMutableArray arrayWithArray:navigationController.viewControllers];
        mainViewController *mainVC = (mainViewController *) [temp lastObject];
        [mainVC showingModel];

    }else if(indexPath.row ==5)
    {
        aboutViewController *trendVC = [[aboutViewController alloc] initWithNibName:@"aboutViewController" bundle:nil];
        UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
        NSMutableArray *temp = [NSMutableArray arrayWithArray:navigationController.viewControllers];
        [temp addObject:trendVC];
        navigationController.viewControllers = temp;
        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    

    
}

@end
