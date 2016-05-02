//
//  categoryManagementViewController.m
//  simpleFinance
//
//  Created by Eric Cao on 5/1/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "categoryManagementViewController.h"
#import "topBarView.h"
#import "global.h"
#import "BottomView.h"
#import "CommonUtility.h"
#import "categoryObject.h"
#import "categoryTableViewCell.h"

@interface categoryManagementViewController ()<UITableViewDataSource,UITableViewDelegate,categoryTapDelegate>
{
    CGFloat bottomHeight;
    BOOL willShowDeleteBtn;
}
@property (nonatomic ,strong) UISegmentedControl *moneyTypeSeg;
@property (nonatomic ,strong) UITableView *categoryTableView;
@property (nonatomic,strong) FMDatabase *db;
@property (nonatomic,strong) NSMutableArray *incomeCategoryArray;
@property (nonatomic,strong) NSMutableArray *expenseCategoryArray;
@end

@implementation categoryManagementViewController
@synthesize db;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    willShowDeleteBtn = NO;
    
    [self prepareCategoryData];
    
    [self configTopbar];
    [self configBottomView];
    [self configCategoryPad];
}

-(void)prepareCategoryData
{
    self.expenseCategoryArray = [[NSMutableArray alloc] init];
    self.incomeCategoryArray = [[NSMutableArray alloc] init];
    
    db = [[CommonUtility sharedCommonUtility] db];
    if (![db open]) {
        NSLog(@"addNewItem/Could not open db.");
        return;
    }
    
    FMResultSet *rs = [db executeQuery:@"select * from CATEGORYINFO where is_deleted = 0"];
    while ([rs next]) {
        categoryObject *oneCategory = [[categoryObject alloc] init];
        
        oneCategory.categoryName = [rs stringForColumn:@"category_name"];
        oneCategory.color_R  = [rs doubleForColumn:@"color_R"];
        oneCategory.color_G = [rs doubleForColumn:@"color_G"];
        oneCategory.color_B = [rs doubleForColumn:@"color_B"];
        
        if ([rs intForColumn:@"category_type"] == 0) {
            [self.expenseCategoryArray addObject:oneCategory];
        }else
        {
            [self.incomeCategoryArray addObject:oneCategory];
        }
    }
    [db close];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)configTopbar
{
    topBarView *topbar = [[topBarView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, topRowHeight)];
    topbar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:topbar];
    
    UIButton * closeViewButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 27, 60, 40)];
    closeViewButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    closeViewButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [closeViewButton setTitle:@"返回" forState:UIControlStateNormal];
    [closeViewButton setTitleColor:   [UIColor colorWithRed:76/255.0f green:101/255.0f blue:120/255.0f alpha:1.0f]forState:UIControlStateNormal];
    [closeViewButton addTarget:self action:@selector(closeVC) forControlEvents:UIControlEventTouchUpInside];
    closeViewButton.backgroundColor = [UIColor clearColor];
    [topbar addSubview:closeViewButton];
    
    UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-65, 27, 60, 40)];
    deleteButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    deleteButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [deleteButton setTitle:@"排序" forState:UIControlStateNormal];
    [deleteButton setTitleColor:   [UIColor colorWithRed:76/255.0f green:101/255.0f blue:120/255.0f alpha:1.0f]forState:UIControlStateNormal];
    [deleteButton addTarget:self action:@selector(deleteItem:) forControlEvents:UIControlEventTouchUpInside];
    deleteButton.backgroundColor = [UIColor clearColor];
    [topbar addSubview:deleteButton];
    
    NSArray *segmentedArray = [[NSArray alloc]initWithObjects:@"支出",@"收入",nil];
    self.moneyTypeSeg = [[UISegmentedControl alloc]initWithItems:segmentedArray];
    self.moneyTypeSeg.frame = CGRectMake(SCREEN_WIDTH*2/7, 30, SCREEN_WIDTH*3/7, 30);
    self.moneyTypeSeg.tintColor =  [UIColor colorWithRed:76/255.0f green:101/255.0f blue:120/255.0f alpha:1.0f];
    self.moneyTypeSeg.selectedSegmentIndex = 0;
    [self.moneyTypeSeg addTarget:self action:@selector(segmentAction:)forControlEvents:UIControlEventValueChanged];  //添加委托方法
    [topbar addSubview:self.moneyTypeSeg];
    
}

-(void)configBottomView
{
    if (IS_IPHONE_6P) {
        bottomHeight = 65;
    }else
    {
        bottomHeight = bottomBar;
    }
    
    
    BottomView *bottomView = [[BottomView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-bottomHeight, SCREEN_WIDTH, bottomHeight)];
    bottomView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:bottomView];
    
    UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH/2-1, bottomHeight)];
    UIButton *addNewButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2, 0, SCREEN_WIDTH/2, bottomHeight)];
    [deleteButton setTitle:@"删减" forState:UIControlStateNormal];
    [addNewButton setTitle:@"添加" forState:UIControlStateNormal];
    deleteButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    deleteButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    addNewButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    addNewButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [deleteButton addTarget:self action:@selector(deleteItem:) forControlEvents:UIControlEventTouchUpInside];
    
    [bottomView addSubview:deleteButton];
    [bottomView addSubview:addNewButton];
    
    UIView *midLine = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 1, 8, 1, bottomHeight-16)];
    midLine.backgroundColor = [UIColor whiteColor];
    [bottomView addSubview:midLine];
    
}


-(void) configCategoryPad
{
    
    
    UITableView *categoryTable = [[UITableView alloc] initWithFrame:CGRectMake(0, topRowHeight +10, SCREEN_WIDTH, SCREEN_HEIGHT - (topRowHeight) - bottomHeight)];
    
    categoryTable.showsVerticalScrollIndicator = YES;
    categoryTable.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    categoryTable.backgroundColor = [UIColor clearColor];
    categoryTable.delegate = self;
    categoryTable.dataSource = self;
    categoryTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    categoryTable.canCancelContentTouches = YES;
    categoryTable.delaysContentTouches = YES;
    self.categoryTableView = categoryTable;
    [self.view addSubview:categoryTable];
}


#pragma mark table delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ((int)(SCREEN_WIDTH/8));
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.moneyTypeSeg.selectedSegmentIndex == 0) {
        return (self.expenseCategoryArray.count/4) + 1;
    }else
    {
        return (self.incomeCategoryArray.count/4) + 1;
    }
}
- (categoryTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"categoryCell";
    
    categoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[categoryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.categoryDelegate = self;
    }
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    if (self.moneyTypeSeg.selectedSegmentIndex == 0) {
        if (self.expenseCategoryArray.count/4 > indexPath.row)
        {
            for (NSInteger  i = 4* indexPath.row; i < 4* (indexPath.row + 1); i++) {
                [tempArray addObject:self.expenseCategoryArray[i]];
            }
        }else
        {
            for (NSInteger  i = 4* indexPath.row; i < self.expenseCategoryArray.count; i++) {
                [tempArray addObject:self.expenseCategoryArray[i]];
            }
        }
    }else
    {
        if (self.incomeCategoryArray.count/4 > indexPath.row)
        {
            for (NSInteger  i = 4* indexPath.row; i < 4* (indexPath.row + 1); i++) {
                [tempArray addObject:self.incomeCategoryArray[i]];
            }
        }else
        {
            for (NSInteger  i = 4* indexPath.row; i < self.incomeCategoryArray.count; i++) {
                [tempArray addObject:self.incomeCategoryArray[i]];
            }
        }
    }
    [cell contentWithCategories:tempArray];
    if (willShowDeleteBtn)
    {
        [cell showDeleteButton];
    }else
    {
        [cell removeDeleteButton];
    }
    
    return cell;
}

-(void)categoryDeleteTap:(UIButton *)sender
{
    NSLog(@"delete..........");
}


-(void)closeVC
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)deleteItem:(UIButton *)sender
{
    NSLog(@"show delete button");
    if (willShowDeleteBtn) {
        [self hideDelete:sender];
    }else
    {

        [self showDelete:sender];
    }
    
}

-(void)showDelete:(UIButton *)sender
{
    [sender setTitle:@"取消" forState:UIControlStateNormal];
    willShowDeleteBtn = YES;
    [self.categoryTableView reloadData];

}
-(void)hideDelete:(UIButton *)sender
{
    [sender setTitle:@"删减" forState:UIControlStateNormal];
    willShowDeleteBtn = NO;
    [self.categoryTableView reloadData];
    
}
-(void)segmentAction:(UISegmentedControl *)Seg{
    NSInteger Index = Seg.selectedSegmentIndex;
    NSLog(@"Index %ld", (long)Index);
    
    
}
@end
