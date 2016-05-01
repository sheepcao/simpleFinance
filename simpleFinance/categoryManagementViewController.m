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

@interface categoryManagementViewController ()
{
    CGFloat bottomHeight;
}
@property (nonatomic ,strong) UISegmentedControl *moneyTypeSeg;
@property (nonatomic ,strong) UITableView *categoryTableView;

@end

@implementation categoryManagementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configTopbar];
    [self configBottomView];
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
    //    categoryTable.canCancelContentTouches = YES;
    //    categoryTable.delaysContentTouches = YES;
    self.categoryTableView = categoryTable;
    [self.view addSubview:categoryTable];
}


-(void)closeVC
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)deleteItem:(UIButton *)sender
{
    
}
-(void)segmentAction:(UISegmentedControl *)Seg{
    NSInteger Index = Seg.selectedSegmentIndex;
    NSLog(@"Index %ld", (long)Index);

    
}
@end
