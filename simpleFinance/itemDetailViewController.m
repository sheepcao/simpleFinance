//
//  itemDetailViewController.m
//  simpleFinance
//
//  Created by Eric Cao on 4/23/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "itemDetailViewController.h"
#import "global.h"
#import "topBarView.h"
#import "itemDetailTableViewCell.h"

@interface itemDetailViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) UITableView *itemInfoTable;
@property (nonatomic,strong) topBarView *topBar;

@end

@implementation itemDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self configTopbar];
    [self configDetailTable];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)configTopbar
{
    self.topBar = [[topBarView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH*3/7)];
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
    [titileLabel setText:@"记账明细"];
    titileLabel.font = [UIFont fontWithName:@"SourceHanSansCN-Normal" size:18.0f];
    titileLabel.textAlignment = NSTextAlignmentCenter;
    [titileLabel setTextColor:[UIColor colorWithRed:76/255.0f green:101/255.0f blue:120/255.0f alpha:1.0f]];
    [self.topBar addSubview:titileLabel];
    
    UILabel *moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, self.topBar.frame.size.height - 70,SCREEN_WIDTH - 80 ,70)];
    UIFontDescriptor *attributeFontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                                 @{UIFontDescriptorFamilyAttribute: @"Helvetica Neue",
                                                   UIFontDescriptorNameAttribute:@"HelveticaNeue-Thin",
                                                   UIFontDescriptorSizeAttribute: [NSNumber numberWithFloat: 42.0f]
                                                   }];
    
    [moneyLabel setFont:[UIFont fontWithDescriptor:attributeFontDescriptor size:0.0]];
    moneyLabel.textColor = TextColor;
    moneyLabel.textAlignment = NSTextAlignmentCenter;
    moneyLabel.adjustsFontSizeToFitWidth = YES;
    [moneyLabel setText:self.money];
    [self.topBar addSubview:moneyLabel];

}

-(void)configDetailTable
{
    self.itemInfoTable = [[UITableView alloc] initWithFrame:CGRectMake(0, SCREEN_WIDTH*3/7 + 10, SCREEN_WIDTH, (SCREEN_HEIGHT- SCREEN_WIDTH/2)*3/4)];
    self.itemInfoTable.showsVerticalScrollIndicator = NO;
    self.itemInfoTable.scrollEnabled = NO;
    self.itemInfoTable.backgroundColor = [UIColor clearColor];
    self.itemInfoTable.delegate = self;
    self.itemInfoTable.dataSource = self;
    self.itemInfoTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.itemInfoTable];
    
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return SCREEN_WIDTH/2;
//}
//- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ((int) SCREEN_WIDTH/8);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}
- (itemDetailTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"itemInfoCell";
    itemDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[itemDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        
    }

    switch (indexPath.row) {
        case 0:
            [cell.leftText setText: @"类别"];
            [cell.rightText setText:self.category];
            break;
        case 1:
            [cell.leftText  setText: @"记账日期"];
            [cell.rightText setText:self.itemCreatedTime];

            break;
        case 2:
            cell.detailTextLabel.textAlignment = NSTextAlignmentCenter;
            [cell.leftText  setText: @"帐目备注"];
            [cell.rightText setText:self.itemDescription];

            break;
            
        default:
            break;
    }
    return cell;
}

-(void)closeVC
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
