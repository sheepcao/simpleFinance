//
//  historyViewController.m
//  simpleFinance
//
//  Created by Eric Cao on 4/26/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "historyViewController.h"
#import "summeryViewController.h"
#import "global.h"
#import "CommonUtility.h"
#import "itemObj.h"
#import "RZTransitions.h"
#import "ChartTableViewCell.h"
#import "RoundedButton.h"
#import "BottomView.h"
#import "addNewItemViewController.h"
#import "myMaskTableViewCell.h"
#import "itemDetailViewController.h"

@interface historyViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>
{
    CGFloat bottomHeight;
    BOOL isSwitchingChart;
    BOOL isShowOutcomeChart;
    NSIndexPath *pieChartIndexPath;

}
@property (strong, nonatomic)  UITableView *maintableView;
@property (nonatomic,strong) summeryViewController *summaryVC;
@property (nonatomic,strong) NSMutableArray *dayItems;
@property (nonatomic,strong) FMDatabase *db;

@property double sumIncome;
@property double sumExpense;
@end

@implementation historyViewController
@synthesize db;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (IS_IPHONE_6P) {
        bottomHeight = 65;
    }else
    {
        bottomHeight = bottomBar;
    }
    
    [self.gradientView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self configTitle];
    [self configSummaryView];
    [self configTable];
    [self configBottomBar];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self prepareData];
    [self.maintableView reloadData];
    [self.maintableView setContentOffset:CGPointMake(0, 0)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)configTitle
{
    UIView *topbar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, topRowHeight)];
    topbar.backgroundColor = [UIColor clearColor];
    [self.gradientView addSubview:topbar];
    
    UIButton * closeViewButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 27, 60, 40)];
    closeViewButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    closeViewButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [closeViewButton setTitle:@"返回" forState:UIControlStateNormal];
    [closeViewButton setTitleColor:   [UIColor colorWithRed:76/255.0f green:101/255.0f blue:120/255.0f alpha:1.0f]forState:UIControlStateNormal];
    [closeViewButton addTarget:self action:@selector(closeVC) forControlEvents:UIControlEventTouchUpInside];
    closeViewButton.backgroundColor = [UIColor clearColor];
    [topbar addSubview:closeViewButton];
    
    UILabel *titileLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 50, 22, 100, 40)];
    [titileLabel setText:@"历史存账"];
    titileLabel.font = [UIFont fontWithName:@"SourceHanSansCN-Normal" size:titleSize];
    titileLabel.textAlignment = NSTextAlignmentCenter;
    [titileLabel setTextColor:[UIColor colorWithRed:76/255.0f green:101/255.0f blue:120/255.0f alpha:1.0f]];
    [topbar addSubview:titileLabel];
}

-(void)configSummaryView
{
    
    self.summaryVC = [[summeryViewController alloc] initWithNibName:@"summeryViewController" bundle:nil];
    self.summaryVC.historyDate = self.recordDate;
    self.summaryVC.isShowDaily = YES;
    [self.summaryVC.view setFrame:CGRectMake(0, topRowHeight+10, SCREEN_WIDTH, summaryViewHeight)];
    self.summaryVC.view.opaque = NO;
    [self addChildViewController:self.summaryVC];
    [self.summaryVC didMoveToParentViewController:self];
    [self.gradientView addSubview:self.summaryVC.view];
    
}

-(void)configTable
{
    CGFloat tableY = self.summaryVC.view.frame.origin.y+self.summaryVC.view.frame.size.height;
    self.maintableView = [[UITableView alloc] initWithFrame:CGRectMake(0, tableY - weekDayBarHeight,SCREEN_WIDTH,SCREEN_HEIGHT- bottomHeight -(tableY - weekDayBarHeight)) style:UITableViewStylePlain];
    self.maintableView.showsVerticalScrollIndicator = NO;
    self.maintableView.backgroundColor = [UIColor clearColor];
    self.maintableView.delegate = self;
    self.maintableView.dataSource = self;
    self.maintableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.maintableView.canCancelContentTouches = YES;
    self.maintableView.delaysContentTouches = YES;
    
    isSwitchingChart = NO;
    isShowOutcomeChart = YES;
    
    [self.gradientView addSubview:self.maintableView];
    [self.gradientView bringSubviewToFront:self.maintableView];
}


-(void)prepareData
{
    self.dayItems = [[NSMutableArray alloc] init];
    
    db = [[CommonUtility sharedCommonUtility] db];
    if (![db open]) {
        NSLog(@"mainVC/Could not open db.");
        return;
    }
    
    NSString *thisDay = self.recordDate;
    NSString *nextEndDay = [[CommonUtility sharedCommonUtility] dateByAddingDays: self.recordDate andDaysToAdd:1];
    
    
    FMResultSet *rs = [db executeQuery:@"select * from ITEMINFO where strftime('%s', target_date) BETWEEN strftime('%s', ?) AND strftime('%s', ?)", thisDay,nextEndDay];
    while ([rs next]) {
        itemObj *oneItem = [[itemObj alloc] init];
        
        oneItem.itemID = [NSNumber numberWithInt: [rs intForColumn:@"item_id"]];
        oneItem.itemCategory  = [rs stringForColumn:@"item_category"];
        oneItem.itemDescription = [rs stringForColumn:@"item_description"];
        oneItem.itemType = [rs intForColumn:@"item_type"];
        oneItem.createdTime = [rs stringForColumn:@"create_time"];
        oneItem.targetTime = [rs stringForColumn:@"target_date"];
        oneItem.moneyAmount = [rs doubleForColumn:@"money"];
        [self.dayItems addObject:oneItem];
        
    }
    //
    FMResultSet *resultIncome = [db executeQuery:@"select sum(money) from ITEMINFO where strftime('%s', target_date) BETWEEN strftime('%s', ?) AND strftime('%s', ?) AND item_type = 1", thisDay,nextEndDay];
    if ([resultIncome next]) {
        double sumIncome =  [resultIncome doubleForColumnIndex:0];
        [self.summaryVC.monthIncome setText:[NSString stringWithFormat:@"%.0f",sumIncome]];
    }
    
    FMResultSet *resultExpense = [db executeQuery:@"select sum(money) from ITEMINFO where strftime('%s', target_date) BETWEEN strftime('%s', ?) AND strftime('%s', ?) AND item_type = 0", thisDay,nextEndDay];
    
    if ([resultExpense next]) {
        double sumExpense =  [resultExpense doubleForColumnIndex:0];
        [self.summaryVC.monthExpense setText:[NSString stringWithFormat:@"%.0f",sumExpense]];
    }
    NSInteger surplus =  [self.summaryVC.monthIncome.text integerValue] - [self.summaryVC.monthExpense.text integerValue];
    [self.summaryVC.monthSurplus setText:[NSString stringWithFormat:@"%ld",(long)surplus]];
    
    [db close];
    
}

-(NSMutableArray *)makePieData:(BOOL)isIncome
{
    self.sumIncome = 0.0f;
    self.sumExpense = 0.0f;
    
    NSMutableArray *itemsArray = [[NSMutableArray alloc] init];
    NSMutableDictionary *itemDic = [[NSMutableDictionary alloc] init];
    
    if (isIncome) {
        for (itemObj *item in self.dayItems) {
            double moneyNow = 0.0;
            if (item.itemType == 1) {
                NSNumber *oneCategoryMoney = [itemDic objectForKey:item.itemCategory];
                if (oneCategoryMoney) {
                    moneyNow = [oneCategoryMoney doubleValue] + item.moneyAmount;
                }else
                {
                    moneyNow = item.moneyAmount;
                }
                [itemDic setObject:[NSNumber numberWithDouble:moneyNow] forKey:item.itemCategory];
                self.sumIncome = self.sumIncome + item.moneyAmount;
            }
        }
        for (NSString *keyCategory in [itemDic allKeys]) {
            NSNumber *moneyEachCategory = [itemDic objectForKey:keyCategory];
            [itemsArray addObject:[PNPieChartDataItem dataItemWithValue:[moneyEachCategory doubleValue] color:[[CommonUtility sharedCommonUtility] categoryColor:keyCategory]
                                                            description:keyCategory]];
        }
    }else
    {
        for (itemObj *item in self.dayItems) {
            double moneyNow = 0.0;
            if (item.itemType == 0) {
                NSNumber *oneCategoryMoney = [itemDic objectForKey:item.itemCategory];
                if (oneCategoryMoney) {
                    moneyNow = [oneCategoryMoney doubleValue] + item.moneyAmount;
                }else
                {
                    moneyNow = item.moneyAmount;
                }
                [itemDic setObject:[NSNumber numberWithDouble:moneyNow] forKey:item.itemCategory];
                
                self.sumExpense = self.sumExpense + item.moneyAmount;
            }
        }
        for (NSString *keyCategory in [itemDic allKeys]) {
            NSNumber *moneyEachCategory = [itemDic objectForKey:keyCategory];
            [itemsArray addObject:[PNPieChartDataItem dataItemWithValue:[moneyEachCategory doubleValue] color:[[CommonUtility sharedCommonUtility] categoryColor:keyCategory]
                                                            description:keyCategory]];
        }
    }
    return itemsArray;
}


-(void)configBottomBar
{
    BottomView *bottomView = [[BottomView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-bottomHeight, SCREEN_WIDTH, bottomHeight)];
    bottomView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:bottomView];
    
    // add new item button----------------------------------------------------
    RoundedButton *addMoneyButton = [[RoundedButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-bottomHeight/2, -9, bottomHeight, bottomHeight)];
    [addMoneyButton setTitle:@"＋" forState:UIControlStateNormal];
    addMoneyButton.titleLabel.font = [UIFont boldSystemFontOfSize:42.0f];
    [addMoneyButton addTarget:self action:@selector(popAddNewView:) forControlEvents:UIControlEventTouchUpInside];
    //for button style on diff states.
    [addMoneyButton addTarget:self action:@selector(tapDownAddNewButton:) forControlEvents:UIControlEventTouchDown];
    [addMoneyButton addTarget:self action:@selector(tapUpAddNewButton:) forControlEvents:UIControlEventTouchCancel];
    [addMoneyButton addTarget:self action:@selector(tapUpAddNewButton:) forControlEvents:UIControlEventTouchDragExit];
    [addMoneyButton addTarget:self action:@selector(tapUpAddNewButton:) forControlEvents:UIControlEventTouchDragOutside];
    [addMoneyButton addTarget:self action:@selector(tapUpAddNewButton:) forControlEvents:UIControlEventTouchUpOutside];
    
    [bottomView addSubview:addMoneyButton];
    
}
-(void)tapDownAddNewButton:(RoundedButton *)sender
{
    [sender selectedStyle];
    
}
-(void)tapUpAddNewButton:(RoundedButton *)sender
{
    [sender notSelectedStyle];
}
-(void)popAddNewView:(RoundedButton *)sender
{
    if (sender) {
        [sender notSelectedStyle];
    }
    
    [self presentViewController:[self nextAddNewItemViewController] animated:YES completion:nil];
    
}

- (UIViewController *)nextAddNewItemViewController
{
    addNewItemViewController* addItemVC = [[addNewItemViewController alloc] init];
    [addItemVC setTransitioningDelegate:[RZTransitionsManager shared]];
    NSString *targetDate = [NSString stringWithFormat:@"%@ 10:10:10",self.recordDate];
    addItemVC.targetDate = targetDate;

    return addItemVC;
}



-(void)closeVC
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.row == self.dayItems.count)
    {
        if (self.dayItems.count == 0) {
            return 60;
        }else
        {
            return PieHeight;
        }
    }else
        return rowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelectRowAtIndexPath");
    
    if (self.dayItems.count == 0)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
        [self popAddNewView:nil];
        });
    }
    
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[myMaskTableViewCell class]]) {
        myMaskTableViewCell *itemCell = (myMaskTableViewCell *)cell;
        [itemCell.category setTextColor:[UIColor colorWithRed:1.0f green:0.65f blue:0.0f alpha:1.0f]];
        
        itemDetailViewController *itemDetailVC = [[itemDetailViewController alloc] initWithNibName:@"itemDetailViewController" bundle:nil];
        NSString *category = @"";
        NSString *categoryOnly = @"";
        NSString *description = @"";
        NSString *money = @"";
        NSString *itemTime = @"";
        NSNumber *itemID = @(-1);
        int itemType = -1;
        
        if (indexPath.row >= self.dayItems.count) {
            return;
        }else
        {
            itemObj *oneItem = self.dayItems[indexPath.row];
            itemID = oneItem.itemID;
            categoryOnly = oneItem.itemCategory;
            description = oneItem.itemDescription;
            itemType = oneItem.itemType;
            if ([[description stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]] isEqualToString:@""]) {
                description = @"无";
            }
            money = [NSString stringWithFormat:@"%.2f",(oneItem.moneyAmount)];
            itemTime = oneItem.createdTime;
            if (oneItem.itemType == 0)
            {
                category = [@"支出 > " stringByAppendingString:categoryOnly];
            }else
            {
                category = [@"收入 > " stringByAppendingString:categoryOnly];
            }
        }
        itemDetailVC.currentItemID = itemID;
        itemDetailVC.itemType = itemType;
        itemDetailVC.category = category;
        itemDetailVC.categoryOnly = categoryOnly;
        itemDetailVC.money = money;
        itemDetailVC.itemDescription = description;
        itemDetailVC.itemCreatedTime = itemTime;
        
        [self.navigationController pushViewController:itemDetailVC animated:YES];
    }
    
    [self tableView:tableView didDeselectRowAtIndexPath:indexPath];
    
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didDeselectRowAtIndexPath");
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[myMaskTableViewCell class]]) {
        myMaskTableViewCell *itemCell = (myMaskTableViewCell *)cell;
        [itemCell.category setTextColor:TextColor];
    }
    
}



#pragma mark -
#pragma mark Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dayItems.count<((self.maintableView.frame.size.height - PieHeight)/rowHeight)?((self.maintableView.frame.size.height - PieHeight)/rowHeight)+1:self.dayItems.count + 1;
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if( indexPath.row == self.dayItems.count)
    {
        
        NSLog(@"row:%ld",(long)indexPath.row);
        
        if (self.dayItems.count == 0)
        {
            NSString *CellIdentifier = @"emptyCell";
            NSLog(@"row:%ld",(long)indexPath.row);
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.backgroundColor = [UIColor clearColor];
                
                NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:@"本日尚无帐目记录"];
                
                UIFontDescriptor *attributeFontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                                             @{UIFontDescriptorFamilyAttribute: @"Avenir Next",
                                                               UIFontDescriptorNameAttribute:@"AvenirNext-Thin",
                                                               UIFontDescriptorSizeAttribute: [NSNumber numberWithFloat: 16.0f]
                                                               }];
                CGAffineTransform matrix =  CGAffineTransformMake(1, 0, tanf(5 * (CGFloat)M_PI / 180), 1, 0, 0);
                attributeFontDescriptor = [attributeFontDescriptor fontDescriptorWithMatrix:matrix];
                [attributedText addAttribute:NSFontAttributeName value:[UIFont fontWithDescriptor:attributeFontDescriptor size:0] range:NSMakeRange(0, attributedText.length)];
                [attributedText addAttribute:NSForegroundColorAttributeName value:TextColor range:NSMakeRange(0, attributedText.length)];
                [attributedText addAttribute:NSUnderlineStyleAttributeName value:@1 range:NSMakeRange(0, attributedText.length)];
                
                [cell.textLabel setAttributedText:attributedText];
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
            }
            
            return cell;
        }
        pieChartIndexPath = indexPath;
        NSString *CellPieIdentifier = @"CellBottom";
        
        ChartTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellPieIdentifier];
        if (cell == nil) {
            cell = [[ChartTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellPieIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
            [cell drawPie];
            [cell.centerButton addTarget:self action:@selector(switchMoneyChart:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        if (isSwitchingChart) {
            NSArray *items;
            cell.pieChart.displayAnimated = YES;
            if (isShowOutcomeChart) {
                items = [self makePieData:YES];
                isShowOutcomeChart = NO;
                [cell switchCenterButtonToOutcome:NO ByMoney:[NSString stringWithFormat:@"%.1f",self.sumIncome]];
            }else{
                items = [self makePieData:NO];
                isShowOutcomeChart = YES;
                [cell switchCenterButtonToOutcome:YES ByMoney:[NSString stringWithFormat:@"%.1f",self.sumExpense]];
                
            }
            
            [cell updatePieWith:items];
            isSwitchingChart = NO;
        }else
        {
            NSArray *items;
            cell.pieChart.displayAnimated = NO;
            if (isShowOutcomeChart) {
                items = [self makePieData:NO];
                [cell switchCenterButtonToOutcome:YES ByMoney:[NSString stringWithFormat:@"%.1f",self.sumExpense]];
                
            }else{
                items = [self makePieData:YES];
                [cell switchCenterButtonToOutcome:NO ByMoney:[NSString stringWithFormat:@"%.1f",self.sumIncome]];
            }
            [cell updatePieWith:items];
        }
        
        
        return cell;
        
    }else if(indexPath.row <self.dayItems.count)
    {
        
        NSLog(@"row:%ld",(long)indexPath.row);
        NSString *CellItemIdentifier = @"Cell1";
        
        myMaskTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellItemIdentifier];
        if (cell == nil) {
            cell = [[myMaskTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellItemIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
            
        }
        NSString *category = @"";
        NSString *description = @"";
        NSString *money = @"";
        
        
        
        
        if(self.dayItems.count>indexPath.row)
        {
            itemObj *oneItem = self.dayItems[indexPath.row];
            category = oneItem.itemCategory;
            description = oneItem.itemDescription;
            if (oneItem.itemType == 0)
            {
                money = [NSString stringWithFormat:@"%.2f",(0 - oneItem.moneyAmount)] ;
                [cell.money setTextColor:[UIColor colorWithRed:72/255.0f green:210/255.0f blue:86/255.0f alpha:1.0f]];
                
            }else
            {
                money =[NSString stringWithFormat:@"+%.2f",(oneItem.moneyAmount)] ;
                [cell.money setTextColor:[UIColor colorWithRed:211/255.0f green:65/255.0f blue:43/255.0f alpha:1.0f]];
                
            }
            
            if (![description isEqualToString:@""]) {
                description = [@" - " stringByAppendingString:description];
            }
        }
        NSString *contentString = [NSString stringWithFormat:@"%@%@",category,description];
        [cell.category setText:contentString];
        [cell.money setText:money];
        
        [cell makeColor:category];
        [cell makeTextStyle];
        return cell;
        
    }else
    {// 补全table content 的实际长度，以便可以滑上去
        NSString *CellIdentifier = @"Cell";
        NSLog(@"row:%ld",(long)indexPath.row);
        
        myMaskTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[myMaskTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
        }
        return cell;
    }
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    for (UITableViewCell *cell in self.maintableView.visibleCells) {
        if ([cell isKindOfClass:[myMaskTableViewCell class]]) {
            myMaskTableViewCell *oneCell = (myMaskTableViewCell *)cell;
            CGFloat hiddenFrameHeight = scrollView.contentOffset.y - cell.frame.origin.y;
            if (hiddenFrameHeight >= 0 || hiddenFrameHeight <= cell.frame.size.height) {
                [oneCell maskCellFromTop:hiddenFrameHeight];
            }
        }else if ([cell isKindOfClass:[ChartTableViewCell class]]) {
            ChartTableViewCell *oneCell = (ChartTableViewCell *)cell;
            CGFloat hiddenFrameHeight = scrollView.contentOffset.y  - cell.frame.origin.y;
            if (hiddenFrameHeight >= 0 || hiddenFrameHeight <= cell.frame.size.height) {
                [oneCell maskCellFromTop:hiddenFrameHeight];
            }
        }
    }
}

-(void)switchMoneyChart:(UIButton *)sender
{
    isSwitchingChart = YES;
    NSArray *indexArray = @[pieChartIndexPath];
    [self.maintableView reloadRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationFade];
}

@end
