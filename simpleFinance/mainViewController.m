//
//  ViewController.m
//  simpleFinance
//
//  Created by Eric Cao on 4/7/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "mainViewController.h"
#import "global.h"
#import "summeryViewController.h"
#import "myMaskTableViewCell.h"
#import "MFSideMenu.h"
#import "ChartTableViewCell.h"
#import "RoundedButton.h"
#import "BottomView.h"
#import "addNewItemViewController.h"
#import "RZTransitions.h"
#import "CommonUtility.h"
#import "itemObj.h"




@interface mainViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>
{
    CGFloat moneyLuckSpace;
    CGFloat bottomHeight;
    CGFloat fontSize;
    NSIndexPath *pieChartIndexPath;
    BOOL isSwitchingChart;
    BOOL isShowOutcomeChart;


}

@property (nonatomic,strong) FMDatabase *db;
@property (nonatomic,strong) summeryViewController *summaryVC;
@property (nonatomic,strong) NSMutableArray *todayItems;

@end

@implementation mainViewController
@synthesize db;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (IS_IPHONE_6P) {
        bottomHeight = 65;
    }else
    {
        bottomHeight = bottomBar;
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(menuStateEventOccurred:)
                                                 name:MFSideMenuStateNotificationEvent
                                               object:nil];
    //add summary view controller as child view controller.
    self.summaryVC = [[summeryViewController alloc] initWithNibName:@"summeryViewController" bundle:nil];
    [self.summaryVC.view setFrame:CGRectMake(0, 0, SCREEN_WIDTH, summaryViewHeight)];
    self.summaryVC.view.opaque = NO;
    [self addChildViewController:self.summaryVC];
    [self.summaryVC didMoveToParentViewController:self];
    
    [self configLuckyText];
    
    self.titleTextLabel.alpha = 1.0f;
    self.moneyBookText.alpha = 0.0f;
    
    self.navigationController.navigationBarHidden = YES;
    self.luckyText.alpha = 1.0f;
    
    self.maintableView = [[UITableView alloc] initWithFrame:CGRectMake(0, topBarHeight, SCREEN_WIDTH, SCREEN_HEIGHT- bottomHeight -topBarHeight) style:UITableViewStylePlain];
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
    
    
    moneyLuckSpace = self.moneyLuckView.frame.size.height + self.moneyLuckView.frame.origin.y - topBarHeight;
    if (IS_IPHONE_5_OR_LESS) {
        moneyLuckSpace = moneyLuckSpace-40;
    }
    NSLog(@"moneyLuckSpace---:%f",moneyLuckSpace);
    
    [self.maintableView addObserver: self forKeyPath: @"contentOffset" options: NSKeyValueObservingOptionNew context: nil];
    
    [self configBottomBar];
    
    [[RZTransitionsManager shared] setAnimationController:[[RZCirclePushAnimationController alloc] init]
                                       fromViewController:[self class]
                                                forAction:RZTransitionAction_PresentDismiss];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (self.maintableView.contentOffset.y > -0.0001 && self.maintableView.contentOffset.y - moneyLuckSpace*2/5 < 0.000001) {
        
        self.luckyText.alpha = 1.0 - self.maintableView.contentOffset.y/(moneyLuckSpace*2/5);
        self.titleTextLabel.alpha = 1.0 - self.maintableView.contentOffset.y/(moneyLuckSpace*2/5);
        self.moneyBookText.alpha = 0.0f;
        
    }else if (self.maintableView.contentOffset.y > -0.0001 && self.maintableView.contentOffset.y - moneyLuckSpace < 0.000001)
    {
        self.moneyBookText.alpha = self.maintableView.contentOffset.y/moneyLuckSpace;
        self.titleTextLabel.alpha = 0.0f;
        self.luckyText.alpha = 0.0f;
        
        
    }else if (self.maintableView.contentOffset.y < -0.00001)
    {
        [self.maintableView setContentOffset:CGPointMake(0, 0)];
    }else
    {
        self.moneyBookText.alpha = 1.0f;
        self.titleTextLabel.alpha = 0.0f;
        self.luckyText.alpha = 0.0f;
    }
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self prepareData];
    NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:1];
    [self.maintableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
    [self.maintableView setContentOffset:CGPointMake(0, 0)];
}

-(void)prepareData
{
    self.todayItems = [[NSMutableArray alloc] init];

    db = [[CommonUtility sharedCommonUtility] db];
    if (![db open]) {
        NSLog(@"mainVC/Could not open db.");
        return;
    }
    

    NSString *yestoday = [[CommonUtility sharedCommonUtility] yesterdayDate];
    NSString *tomorrow = [[CommonUtility sharedCommonUtility] tomorrowDate];
    NSString *startMonthDay = [[CommonUtility sharedCommonUtility] firstMonthDate];
    NSString *endMonthDay = [[CommonUtility sharedCommonUtility] lastMonthDate];

    FMResultSet *rs = [db executeQuery:@"select * from ITEMINFO where create_time > ? AND create_time < ?", yestoday,tomorrow];
    while ([rs next]) {
        itemObj *oneItem = [[itemObj alloc] init];
        
        oneItem.itemID = [NSNumber numberWithInt: [rs intForColumn:@"item_id"]];
        
        oneItem.itemCategory  = [rs stringForColumn:@"item_category"];
        oneItem.itemDescription = [rs stringForColumn:@"item_description"];
        oneItem.itemType = [rs intForColumn:@"item_type"];
        oneItem.createdTime = [rs stringForColumn:@"create_time"];
        oneItem.moneyAmount = [rs doubleForColumn:@"money"];
        [self.todayItems addObject:oneItem];
        
    }
//    
    FMResultSet *resultIncome = [db executeQuery:@"select sum(money) from ITEMINFO where create_time >= ? AND create_time < ? AND item_type = 1", startMonthDay,endMonthDay];
    if ([resultIncome next]) {
       double sumIncome =  [resultIncome doubleForColumnIndex:0];
        [self.summaryVC.monthIncome setText:[NSString stringWithFormat:@"%.0f",sumIncome]];
    }
    
    FMResultSet *resultExpense = [db executeQuery:@"select sum(money) from ITEMINFO where create_time >= ? AND create_time < ? AND item_type = 0", startMonthDay,endMonthDay];
    
    if ([resultExpense next]) {
        double sumExpense =  [resultExpense doubleForColumnIndex:0];
        [self.summaryVC.monthExpense setText:[NSString stringWithFormat:@"%.0f",sumExpense]];
    }
    NSInteger surplus =  [self.summaryVC.monthIncome.text integerValue] - [self.summaryVC.monthExpense.text integerValue];
    [self.summaryVC.monthSurplus setText:[NSString stringWithFormat:@"%ld",(long)surplus]];
    
//    [self.summaryVC.view setNeedsDisplay];
    
    [db close];

}

-(void)configLuckyText
{
    
    
    if (IS_IPHONE_5_OR_LESS) {
        fontSize = 12.5f;
    }else if(IS_IPHONE_6)
    {
        fontSize = 14.0f;
    }else
    {
        fontSize = 15.5f;
    }
    
    
    UIFontDescriptor *attributeFontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                                 @{UIFontDescriptorFamilyAttribute: @"Source Han Sans CN",
                                                   UIFontDescriptorNameAttribute:@"SourceHanSansCN-Normal",
                                                   UIFontDescriptorSizeAttribute: [NSNumber numberWithFloat: fontSize]
                                                   }];
    
    CGAffineTransform matrix =  CGAffineTransformMake(1, 0, tanf(12 * (CGFloat)M_PI / 180), 1, 0, 0);
    attributeFontDescriptor = [attributeFontDescriptor fontDescriptorWithMatrix:matrix];
    self.luckyText.font = [UIFont fontWithDescriptor:attributeFontDescriptor size:0.0];
    
    NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString:@"\t理财敏感度高，适合做长远布局，尤其是不用辛苦上班就可以有收益这类的被动收入，如房租、股权分红等等值得挖掘。"];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineSpacing:attributeFontDescriptor.pointSize *0.43];
    [attrString addAttribute:NSParagraphStyleAttributeName
                       value:style
                       range:NSMakeRange(0, attrString.length)];
    self.luckyText.attributedText = attrString;
    self.luckyText.numberOfLines = 6;
    self.luckyText.alpha = 1.0f;
    self.luckyText.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.45];
    self.luckyText.shadowOffset =  CGSizeMake(0, 0.5);
    
    
//    
//            for(NSString *fontfamilyname in [UIFont familyNames])
//            {
//                NSLog(@"family:'%@'",fontfamilyname);
//                for(NSString *fontName in [UIFont fontNamesForFamilyName:fontfamilyname])
//                {
//                    NSLog(@"\tfont:'%@'",fontName);
//                }
//                NSLog(@"-------------");
//            }
//            NSLog(@"========%d Fonts",[UIFont familyNames].count);
//    
//    
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

    return addItemVC;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return moneyLuckSpace;
    }else if(indexPath.section == 1 && indexPath.row == self.todayItems.count)
    {
        if (self.todayItems.count == 0) {
            return 60;
        }else
        {
            return PieHeight;
        }
    }
    else
        return rowHeight;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    }else if (section == 1) {
        return summaryViewHeight;
    }else
        return 0;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelectRowAtIndexPath");
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[myMaskTableViewCell class]]) {
        myMaskTableViewCell *itemCell = (myMaskTableViewCell *)cell;
        [itemCell.category setTextColor:[UIColor colorWithRed:1.0f green:0.65f blue:0.0f alpha:1.0f]];
//        [itemCell.money setTextColor:[UIColor colorWithRed:1.0f green:0.65f blue:0.0f alpha:1.0f]];
    }
    
    if (indexPath.section == 1) {
        if (self.todayItems.count == 0)
        {
            [self popAddNewView:nil];
        }
    }

}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didDeselectRowAtIndexPath");
    myMaskTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell.category setTextColor:TextColor];
    
}



#pragma mark -
#pragma mark Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView             // Default is 1 if not implemented
{
    return 2;
}
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 0 )
    {
        return nil;
    }else if (section == 1)
    {

        return self.summaryVC.view;
    }else
        return nil;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return 1;
    }else if(section == 1)
    {
        return self.todayItems.count<((self.maintableView.frame.size.height-summaryViewHeight - PieHeight)/rowHeight)?((self.maintableView.frame.size.height-summaryViewHeight - PieHeight)/rowHeight)+1:self.todayItems.count + 1;
    }else
        return self.todayItems.count;
    
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        static NSString *CellIdentifier = @"Cell";
        
        myMaskTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[myMaskTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
        }
        
        return cell;
        
    }
    
    else if(indexPath.section == 1 && indexPath.row == self.todayItems.count)
    {
     
        NSLog(@"row:%ld",(long)indexPath.row);
        
        if (self.todayItems.count == 0)
        {
            static NSString *CellIdentifier = @"emptyCell";
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
        static NSString *CellPieIdentifier = @"CellBottom";

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
                items = @[[PNPieChartDataItem dataItemWithValue:30 color:PNTwitterColor
                                                             description:@"吃喝玩乐"],
                                   [PNPieChartDataItem dataItemWithValue:60 color:PNMauve description:@"阅读"],
                                   ];
                isShowOutcomeChart = NO;
                [cell switchCenterButtonToOutcome:NO ByMoney:@"12000"];
            }else{
                items = @[[PNPieChartDataItem dataItemWithValue:40 color:PNRed
                                                    description:@"吃喝玩乐"],
                          [PNPieChartDataItem dataItemWithValue:20 color:PNBlue description:@"阅读"],
                          [PNPieChartDataItem dataItemWithValue:20 color:PNGreen description:@"一般消费"],
                          ];
                isShowOutcomeChart = YES;
                [cell switchCenterButtonToOutcome:YES ByMoney:@"580"];

            }

            [cell updatePieWith:items];
            isSwitchingChart = NO;
        }else
        {
            NSArray *items;
            cell.pieChart.displayAnimated = NO;
            if (isShowOutcomeChart) {
                items = @[[PNPieChartDataItem dataItemWithValue:40 color:PNRed
                                                    description:@"吃喝玩乐"],
                          [PNPieChartDataItem dataItemWithValue:20 color:PNBlue description:@"阅读"],
                          [PNPieChartDataItem dataItemWithValue:20 color:PNGreen description:@"一般消费"],
                          ];
                [cell switchCenterButtonToOutcome:YES ByMoney:@"580"];
        
            }else{
                items = @[[PNPieChartDataItem dataItemWithValue:30 color:PNTwitterColor
                                                    description:@"吃喝玩乐"],
                          [PNPieChartDataItem dataItemWithValue:60 color:PNMauve description:@"阅读"],
                          ];
                [cell switchCenterButtonToOutcome:NO ByMoney:@"12000"];
            }
            [cell updatePieWith:items];
        }
        
        
        return cell;
        
    }else if(indexPath.section == 1 && indexPath.row <self.todayItems.count)
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


        if(self.todayItems.count>indexPath.row)
        {
            itemObj *oneItem = self.todayItems[indexPath.row];
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
        [cell.seperator setBackgroundColor:[UIColor purpleColor]];
        [cell.money setText:money];
        
        [cell makeTextStyle];
        return cell;
        
    }else
    {// 补全table content 的实际长度，以便可以滑上去
        static NSString *CellIdentifier = @"Cell";
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
            CGFloat hiddenFrameHeight = scrollView.contentOffset.y + summaryViewHeight - cell.frame.origin.y;
            if (hiddenFrameHeight >= 0 || hiddenFrameHeight <= cell.frame.size.height) {
                [oneCell maskCellFromTop:hiddenFrameHeight];
            }
        }else if ([cell isKindOfClass:[ChartTableViewCell class]]) {
            ChartTableViewCell *oneCell = (ChartTableViewCell *)cell;
            CGFloat hiddenFrameHeight = scrollView.contentOffset.y + summaryViewHeight - cell.frame.origin.y;
            if (hiddenFrameHeight >= 0 || hiddenFrameHeight <= cell.frame.size.height) {
                [oneCell maskCellFromTop:hiddenFrameHeight];
            }
        }
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView// called when scroll view grinds to a halt
{
    if (scrollView.contentOffset.y<moneyLuckSpace && scrollView.contentOffset.y>0.001) {
        [UIView animateWithDuration:0.35f animations:^(void){
            [scrollView setContentOffset:CGPointMake(0, moneyLuckSpace)];
        }];
    }else
        return;
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView.contentOffset.y<moneyLuckSpace && scrollView.contentOffset.y>0.001) {
        
        if (!decelerate) {
            [UIView animateWithDuration:0.35f animations:^(void){
                [scrollView setContentOffset:CGPointMake(0, moneyLuckSpace)];
            }];
        }else
            return;
        
    }else
        return;
}





- (IBAction)skinChange:(UIButton *)sender {
    NSLog(@"skinChange");
    if (sender.tag == 1) {
        self.gradientView.inputColor0 = [UIColor darkGrayColor];
        self.gradientView.inputColor1 = [UIColor blackColor];
        [sender setTitle:@"白" forState:UIControlStateNormal];
        [self.gradientView setNeedsDisplay];
        sender.tag = 10;
        
    }else
    {
        self.gradientView.inputColor0 = [UIColor colorWithRed:89/255.0f green:175/255.0f blue:185/255.0f alpha:1.0f];
        self.gradientView.inputColor1 = [UIColor colorWithRed:26/255.0f green:130/255.0f blue:195/255.0f alpha:1.0f];
        [sender setTitle:@"夜" forState:UIControlStateNormal];
        sender.tag = 1;
        
        [self.gradientView setNeedsDisplay];
    }
    
}

- (IBAction)menuTapped:(id)sender {
    [self.menuContainerViewController toggleRightSideMenuCompletion:^{
        
    }];
    
}

- (void)menuStateEventOccurred:(NSNotification *)notification {
    
    NSLog(@"eventType:%@",[[notification userInfo] objectForKey:@"eventType"]);
    
    
    if ([[[notification userInfo] objectForKey:@"eventType"] intValue] == MFSideMenuStateEventMenuDidClose) {
        self.menuContainerViewController.panMode = MFSideMenuPanModeNone ;
        
    }else if([[[notification userInfo] objectForKey:@"eventType"] intValue] == MFSideMenuStateEventMenuDidOpen)
    {
        self.menuContainerViewController.panMode = MFSideMenuPanModeDefault ;
    }
}

-(void)switchMoneyChart:(UIButton *)sender
{
    NSLog(@"oooooo");
    isSwitchingChart = YES;
    
    
    NSArray *indexArray = @[pieChartIndexPath];
    [self.maintableView reloadRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationFade];
}

@end
