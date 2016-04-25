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
#import "CommonUtility.h"
#import "addNewItemViewController.h"
#import "RZTransitions.h"


@interface itemDetailViewController ()<UITableViewDataSource,UITableViewDelegate,reloadDataDelegate>
@property (nonatomic,strong) UITableView *itemInfoTable;
@property (nonatomic,strong) topBarView *topBar;
@property (nonatomic,strong) FMDatabase *db;
@property (nonatomic,strong) UILabel *itemMoneyLabel;

@end

@implementation itemDetailViewController
@synthesize db;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self configTopbar];
    [self configDetailTable];
    [self configButton];
    
    [[RZTransitionsManager shared] setAnimationController:[[RZCirclePushAnimationController alloc] init]
                                       fromViewController:[self class]
                                                forAction:RZTransitionAction_PresentDismiss];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)refreshData
{
    db = [[CommonUtility sharedCommonUtility] db];
    if (![db open]) {
        NSLog(@"mainVC/Could not open db.");
        return;
    }
    
    FMResultSet *rs = [db executeQuery:@"select * from ITEMINFO where item_id = ?", self.currentItemID];
    while ([rs next]) {
        
        self.categoryOnly  = [rs stringForColumn:@"item_category"];
        self.itemType = [rs intForColumn:@"item_type"];
        if (self.itemType == 0)
        {
            self.category = [@"支出 > " stringByAppendingString:self.categoryOnly];
        }else
        {
            self.category = [@"收入 > " stringByAppendingString:self.categoryOnly];
        }

        self.itemDescription = [rs stringForColumn:@"item_description"];
        self.money = [NSString stringWithFormat:@"%.2f", [rs doubleForColumn:@"money"]];
        
    }

    [self.itemInfoTable reloadData];
    [self.itemMoneyLabel setText:self.money];
    
    [db close];
    
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
    titileLabel.font = [UIFont fontWithName:@"SourceHanSansCN-Normal" size:17.0f];
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
    self.itemMoneyLabel  = moneyLabel;
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

-(void)configButton
{
    UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/5, self.itemInfoTable.frame.origin.y + self.itemInfoTable.frame.size.height + 20, SCREEN_WIDTH/5,SCREEN_WIDTH/5 )];
    [deleteButton setTitle:@"删除" forState:UIControlStateNormal];
    [deleteButton addTarget:self action:@selector(deleteTap) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *editButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-SCREEN_WIDTH/5-deleteButton.frame.size.width, deleteButton.frame.origin.y,deleteButton.frame.size.width,deleteButton.frame.size.height)];
    [editButton setTitle:@"编辑" forState:UIControlStateNormal];
    [editButton addTarget:self action:@selector(editTap) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:deleteButton];
    [self.view addSubview:editButton];

}

-(void)deleteTap
{
    NSInteger itemID = [self.currentItemID integerValue];
    if(itemID >=0)
    {
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"" message:@"永久删除这笔账目?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* yesAction = [UIAlertAction actionWithTitle:@"是的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            db = [[CommonUtility sharedCommonUtility] db];
            if (![db open]) {
                NSLog(@"mainVC/Could not open db.");
                return;
            }
            
            NSString *sqlCommand = [NSString stringWithFormat:@"delete from ITEMINFO where item_id=%ld",(long)itemID];
            BOOL sql = [db executeUpdate:sqlCommand];
            if (!sql) {
                NSLog(@"ERROR: %d - %@", db.lastErrorCode, db.lastErrorMessage);
            }
            [db close];
            [self closeVC];
        }];
        
        UIAlertAction* noAction = [UIAlertAction actionWithTitle:@"不" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
        [alert addAction:yesAction];
        [alert addAction:noAction];
        [self presentViewController:alert animated:YES completion:nil];

    }
}
-(void)editTap
{
    [self presentViewController:[self nextAddNewItemViewController] animated:YES completion:nil];
}

- (UIViewController *)nextAddNewItemViewController
{
    addNewItemViewController* addItemVC = [[addNewItemViewController alloc] init];
    addItemVC.isEditing =  YES;
    addItemVC.isEditingIncome = self.itemType;
    addItemVC.editingID = self.currentItemID;
    addItemVC.editingCategory = self.categoryOnly;
    addItemVC.editingMoney = self.money;
    addItemVC.editingNote = self.itemDescription;
    addItemVC.refreshDelegate = self;
    [addItemVC setTransitioningDelegate:[RZTransitionsManager shared]];
    
    return addItemVC;
}

-(void)closeVC
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
