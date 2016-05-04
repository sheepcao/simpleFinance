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
#import "trendViewController.h"
#import "categoryManagementViewController.h"
#import "mainViewController.h"

@interface SideMenuViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) NSArray *menuArray;
@end

@implementation SideMenuViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.menuArray = @[@"同 步 | 备 份",@"分类管理",@"流水明细",@"历史走势",@"显示模式",@"设置"];
    
    UITableView *menuTable = [[UITableView alloc] initWithFrame:CGRectMake(0, (SCREEN_HEIGHT-6*(SCREEN_WIDTH/5.5))*2/3, SCREEN_WIDTH*2/3, 6*(SCREEN_WIDTH/5.5))];
    menuTable.delegate = self;
    menuTable.dataSource = self;
    menuTable.scrollEnabled = NO;
    menuTable.backgroundColor = [UIColor clearColor];
    menuTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:menuTable];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@", self.menuArray[indexPath.row]];
    cell.textLabel.textColor = TextColor;
    UIFontDescriptor *attributeFontDescriptorFirstPart = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                                          @{UIFontDescriptorFamilyAttribute: @"Source Han Sans CN",
                                                            UIFontDescriptorNameAttribute:@"SourceHanSansCN-Normal",
                                                            UIFontDescriptorSizeAttribute: [NSNumber numberWithFloat: SCREEN_WIDTH/20]
                                                            }];
    [cell.textLabel setFont:[UIFont fontWithDescriptor:attributeFontDescriptorFirstPart size:0.0f]];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    return cell;
}


#pragma mark -
#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row ==1) {
        categoryManagementViewController *trendVC = [[categoryManagementViewController alloc] initWithNibName:@"categoryManagementViewController" bundle:nil];
        UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
        NSMutableArray *temp = [NSMutableArray arrayWithArray:navigationController.viewControllers];
        [temp addObject:trendVC];
        navigationController.viewControllers = temp;
        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];

    }else if(indexPath.row ==2)
    {

        
        
    }else if (indexPath.row == 3) {
        trendViewController *trendVC = [[trendViewController alloc] initWithNibName:@"trendViewController" bundle:nil];
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
        
        
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    

    
}

@end
