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
#import "pieViewController.h"
#import "RZTransitions.h"
#import "CommonUtility.h"
#import "itemObj.h"
#import "itemDetailViewController.h"
#import "trendViewController.h"
#import "AppDelegate.h"
#import "constellationView.h"
#import "pickerLabel.h"

@interface mainViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate,constellationDelegate>
{
    CGFloat moneyLuckSpace;
    CGFloat bottomHeight;
    CGFloat fontSize;
    NSIndexPath *pieChartIndexPath;
    BOOL isSwitchingChart;
    BOOL isShowOutcomeChart;
    NSArray *constellationList;
    NSString *constellationSelected;

}

@property (nonatomic,strong) FMDatabase *db;
@property (nonatomic,strong) summeryViewController *summaryVC;
@property (nonatomic,strong) NSMutableArray *todayItems;
@property (nonatomic,strong) UIView *myDimView;
@property (nonatomic,strong)  constellationView *myConstellView;
@property double sumIncome;
@property double sumExpense;


@end

@implementation mainViewController
@synthesize db;

- (void)registerLuckChangedNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(configLuckyText)
                                                 name:LuckChanged
                                               object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"main view....");
    [self registerLuckChangedNotification];
    
    if (IS_IPHONE_6P) {
        bottomHeight = 65;
    }else
    {
        bottomHeight = bottomBar;
    }
    
    constellationList = [[NSArray alloc]initWithObjects:@"白羊座     3.21-4.19",@"金牛座     4.20-5.20",@"双子座     5.21-6.21",@"巨蟹座     6.22-7.22",@"狮子座     7.23-8.22",@"处女座     8.23-9.22",@"天秤座     9.23-10.23",@"天蝎座     10.24-11.22",@"射手座     11.23-12.21",@"摩羯座     12.22-1.19",@"水瓶座     1.20-2.18",@"双鱼座     2.19-3.20",nil];
    constellationSelected = constellationList[0];
    
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
    self.maintableView.bounces = NO;
    
    isSwitchingChart = NO;
    isShowOutcomeChart = YES;
    
    [self.view addSubview:self.maintableView];
    [self.view bringSubviewToFront:self.maintableView];
    
    
    moneyLuckSpace = self.moneyLuckView.frame.size.height + self.moneyLuckView.frame.origin.y - topBarHeight;
    if (IS_IPHONE_5) {
        moneyLuckSpace = moneyLuckSpace-58;
    }else if (IS_IPHONE_4_OR_LESS)
    {
        moneyLuckSpace = moneyLuckSpace-76;
    }else if(IS_IPHONE_6P)
    {
        moneyLuckSpace = moneyLuckSpace-20;
    }else
    {
        moneyLuckSpace = moneyLuckSpace-38;

    }
    NSLog(@"moneyLuckSpace---:%f",moneyLuckSpace);
    
    if ([CommonUtility isSystemLangChinese]) {
        [self.maintableView addObserver: self forKeyPath: @"contentOffset" options: NSKeyValueObservingOptionNew context: nil];
    }else
    {
        self.moneyBookText.alpha = 1.0f;
        self.titleTextLabel.alpha =0.0f;
        self.luckyText.alpha = 0.0f;
    }
    
    [self configBottomBar];
    
    [[RZTransitionsManager shared] setAnimationController:[[RZCirclePushAnimationController alloc] init]
                                       fromViewController:[self class]
                                                forAction:RZTransitionAction_PresentDismiss];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (self.maintableView.contentOffset.y > -0.0001 && self.maintableView.contentOffset.y - moneyLuckSpace*2/5 < 0.000001) {
        
        self.luckyText.alpha = 1.0 - self.maintableView.contentOffset.y/(moneyLuckSpace*1/3);
        self.titleTextLabel.alpha = 1.0 - self.maintableView.contentOffset.y/(moneyLuckSpace*1/3);
        self.moneyBookText.alpha = 0.0f;
        
    }else if (self.maintableView.contentOffset.y > -0.0001 && self.maintableView.contentOffset.y - moneyLuckSpace < 0.000001)
    {
        self.moneyBookText.alpha = (self.maintableView.contentOffset.y - moneyLuckSpace*2/5)/(moneyLuckSpace*3/5);
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
    [self.maintableView setContentOffset:CGPointMake(0, 0)];

    [super viewWillAppear:animated];
    [self prepareData];
    NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:1];
    [self.maintableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
}

-(void)prepareData
{
    self.todayItems = [[NSMutableArray alloc] init];
    
    db = [[CommonUtility sharedCommonUtility] db];
    if (![db open]) {
        NSLog(@"mainVC/Could not open db.");
        return;
    }
    
    NSString *today = [[CommonUtility sharedCommonUtility] todayDate];
    NSString *tomorrow = [[CommonUtility sharedCommonUtility] tomorrowDate];
    NSString *startMonthDay = [[CommonUtility sharedCommonUtility] firstMonthDate];
    NSString *endMonthDay = [[CommonUtility sharedCommonUtility] firstNextMonthDate];
    FMResultSet *rs = [db executeQuery:@"select * from ITEMINFO where strftime('%s', target_date) BETWEEN strftime('%s', ?) AND strftime('%s', ?)", today,tomorrow];
    while ([rs next]) {
        itemObj *oneItem = [[itemObj alloc] init];
        
        oneItem.itemID = [NSNumber numberWithInt: [rs intForColumn:@"item_id"]];
        
        oneItem.itemCategory  = [rs stringForColumn:@"item_category"];
        oneItem.itemDescription = [rs stringForColumn:@"item_description"];
        oneItem.itemType = [rs intForColumn:@"item_type"];
        oneItem.createdTime = [rs stringForColumn:@"create_time"];
        oneItem.targetTime = [rs stringForColumn:@"target_date"];
        oneItem.moneyAmount = [rs doubleForColumn:@"money"];
        [self.todayItems addObject:oneItem];
        
    }
    //
    FMResultSet *resultIncome = [db executeQuery:@"select sum(money) from ITEMINFO where strftime('%s', target_date) BETWEEN strftime('%s', ?) AND strftime('%s', ?) AND item_type = 1", startMonthDay,endMonthDay];
    if ([resultIncome next]) {
        double sumIncome =  [resultIncome doubleForColumnIndex:0];
        [self.summaryVC.monthIncome setText:[NSString stringWithFormat:@"%.0f",sumIncome]];
    }
    
    FMResultSet *resultExpense = [db executeQuery:@"select sum(money) from ITEMINFO where strftime('%s', target_date) BETWEEN strftime('%s', ?) AND strftime('%s', ?) AND item_type = 0", startMonthDay,endMonthDay];
    
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
        for (itemObj *item in self.todayItems) {
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
        for (itemObj *item in self.todayItems) {
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

-(void)configLuckyText
{
    
    NSString *Constellation = [[NSUserDefaults standardUserDefaults] objectForKey:@"Constellation"];
    NSLog(@"~~~!!!!!~~~~~constellation:%@",Constellation);
    if (!Constellation) {
        [self.luckyText makeText:@"设置星座，随时掌握财运 >"];
        return;
    }
    
    if ([CommonUtility isSystemLangChinese]) {
        [[CommonUtility sharedCommonUtility] fetchConstellation:Constellation ForView:self.luckyText];
    }
    

}

- (IBAction)configConstellation:(id)sender {
    
    constellationView *constellView = [[constellationView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    constellView.constellPicker.delegate = self;
    constellView.constellPicker.dataSource = self;
    constellView.constellDelegate = self;
    [constellView addGesture];
    [constellView.constellPicker selectRow:12*1000 inComponent:0 animated:NO];
    self.myConstellView = constellView;
    [self.view addSubview:constellView];
    
}

-(void)constellationChoose
{
    NSString *constellationOnly = [constellationSelected componentsSeparatedByString:@" "][0];

    [[NSUserDefaults standardUserDefaults] setObject:constellationOnly forKey:@"Constellation"];
    if ([CommonUtility isSystemLangChinese]) {
        [[CommonUtility sharedCommonUtility] fetchConstellation:constellationOnly ForView:self.luckyText];
    }
    
    if ([self.luckyText.text isEqualToString:@"设置星座，随时掌握财运 >"]) {
        [UIView animateWithDuration:0.35f animations:^(void){
            [self.maintableView setContentOffset:CGPointMake(0, moneyLuckSpace)];
        }];
    }
        [self.myConstellView removeDimView];

}
-(void)cancelConstellation
{
    [self.myConstellView removeDimView];
}

#pragma mark picker delegate
// pickerView 列数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view
{
    pickerLabel *picker = [[pickerLabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 60, 38)];
    [picker makeText:[constellationList objectAtIndex:(row%[constellationList count])]];
    return picker;
}



// pickerView 每列个数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [constellationList count] + 1000000;
}

// 每列宽度
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {

    return SCREEN_WIDTH-60;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 38;
}
// 返回选中的行
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
        constellationSelected = [constellationList objectAtIndex:(row%[constellationList count])];
}

//返回当前行的内容,此处是将数组中数值添加到滚动的那个显示栏上
-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
        return [constellationList objectAtIndex:(row%[constellationList count])];
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
    
    UIButton *pieButton = [[UIButton alloc] initWithFrame:CGRectMake(15, 10, bottomHeight-20, bottomHeight-20)];
    [pieButton setBackgroundColor:[UIColor clearColor]];
    [pieButton setTitle:@"饼" forState:UIControlStateNormal];
    [pieButton addTarget:self action:@selector(popPieView) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:pieButton];
    
    UIButton *TrendButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 15 - (bottomHeight-20), 10, bottomHeight-20, bottomHeight-20)];
    [TrendButton setBackgroundColor:[UIColor clearColor]];
    [TrendButton setTitle:@"条" forState:UIControlStateNormal];
    [TrendButton addTarget:self action:@selector(popTrendView) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:TrendButton];
    
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
    
    NSDate *targetDay = [NSDate date];
    NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
    [dateFormatter1 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSCalendar *cal = [[NSCalendar alloc]
                       initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    dateFormatter1.calendar = cal;
    
    NSString *targetDate = [dateFormatter1 stringFromDate:targetDay];
    addItemVC.targetDate = targetDate;
    
    return addItemVC;
}

-(void)popPieView
{
    [self.navigationController pushViewController:[self nextPieViewController] animated:YES];
    
}
- (UIViewController *)nextPieViewController
{
    pieViewController* addItemVC = [[pieViewController alloc] init];
    [addItemVC setTransitioningDelegate:[RZTransitionsManager shared]];
    
    return addItemVC;
}

-(void)popTrendView
{
    trendViewController *trendVC = [[trendViewController alloc] initWithNibName:@"trendViewController" bundle:nil];
    [self.navigationController pushViewController:trendVC animated:YES];
    
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
        if ([CommonUtility isSystemLangChinese]) {
            return moneyLuckSpace;
        }
        return 0;
    }else if(indexPath.section == 1 && indexPath.row == self.todayItems.count){
        if (self.todayItems.count == 0) {
            return rowHeight;
        }else
        {
            return PieHeight;
        }
    }else
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
    NSLog(@"didSelectRowAtIndexPath:%ld",(long)indexPath.section);
    
    if (indexPath.section == 0) {
        [self configConstellation:nil];
    }
    
    if (indexPath.section == 1) {
        if (self.todayItems.count == 0)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self popAddNewView:nil];
            });
        }
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
        
        if (indexPath.row >= self.todayItems.count) {
            return;
        }else
        {
            itemObj *oneItem = self.todayItems[indexPath.row];
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
         if (self.todayItems.count == 0) {
             if (IS_IPHONE_6P || IS_IPHONE_4_OR_LESS) {
                 return ((self.maintableView.frame.size.height-summaryViewHeight )/rowHeight);
             }else
                 return ((self.maintableView.frame.size.height-summaryViewHeight )/rowHeight)+1;
         }
        
        return self.todayItems.count<((self.maintableView.frame.size.height-summaryViewHeight - PieHeight)/rowHeight)?((self.maintableView.frame.size.height-summaryViewHeight - PieHeight)/rowHeight)+1:self.todayItems.count + 1;
    }else
        return self.todayItems.count;
    
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        NSString *CellIdentifier = @"Cell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
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
                [cell.money setTextColor:[UIColor colorWithRed:72/255.0f green:210/255.0f blue:86/255.0f alpha:0.92f]];
                
            }else
            {
                money =[NSString stringWithFormat:@"+%.2f",(oneItem.moneyAmount)] ;
                [cell.money setTextColor:[UIColor colorWithRed:211/255.0f green:65/255.0f blue:43/255.0f alpha:0.92f]];
                
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
    if ([CommonUtility isSystemLangChinese] && scrollView.contentOffset.y<moneyLuckSpace && scrollView.contentOffset.y>0.001) {

//    if (scrollView.contentOffset.y<moneyLuckSpace && scrollView.contentOffset.y>0.001) {
        [UIView animateWithDuration:0.35f animations:^(void){
            [scrollView setContentOffset:CGPointMake(0, moneyLuckSpace)];
        }];
    }else
        return;
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([CommonUtility isSystemLangChinese] && scrollView.contentOffset.y<moneyLuckSpace && scrollView.contentOffset.y>0.001) {

//    if (scrollView.contentOffset.y<moneyLuckSpace && scrollView.contentOffset.y>0.001) {
        
        if (!decelerate) {
            [UIView animateWithDuration:0.35f animations:^(void){
                [scrollView setContentOffset:CGPointMake(0, moneyLuckSpace)];
            }];
        }else
            return;
        
    }else
        return;
}

//- (IBAction)skinChange:(UIButton *)sender {
//    NSLog(@"skinChange");
//    if (sender.tag == 1) {
//        self.gradientView.inputColor0 = [UIColor darkGrayColor];
//        self.gradientView.inputColor1 = [UIColor blackColor];
//        [sender setTitle:@"白" forState:UIControlStateNormal];
//        [self.gradientView setNeedsDisplay];
//        sender.tag = 10;
//
//    }else
//    {
//        self.gradientView.inputColor0 = [UIColor colorWithRed:89/255.0f green:175/255.0f blue:185/255.0f alpha:1.0f];
//        self.gradientView.inputColor1 = [UIColor colorWithRed:26/255.0f green:130/255.0f blue:195/255.0f alpha:1.0f];
//        [sender setTitle:@"夜" forState:UIControlStateNormal];
//        sender.tag = 1;
//
//        [self.gradientView setNeedsDisplay];
//    }
//
//}

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

-(void)showingModel
{
    NSLog(@"showing.....");
    UIView *dimView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    dimView.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.7];
    [self.view addSubview:dimView];
    self.myDimView = dimView;
    
    UIView *gestureView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT*3/4)];
    gestureView.backgroundColor = [UIColor clearColor];
    [dimView addSubview:gestureView];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [gestureView addGestureRecognizer:tap];
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT/4)];
    contentView.tag = 100;
    contentView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.9 alpha:0.9f];
    [dimView addSubview:contentView];
    [UIView animateWithDuration:0.32f delay:0.15f options:UIViewAnimationOptionLayoutSubviews animations:^{
        if (contentView) {
            [contentView setFrame:CGRectMake(contentView.frame.origin.x, SCREEN_HEIGHT*3/4, contentView.frame.size.width, contentView.frame.size.height)];
        }
    } completion:nil ];
    

    UILabel *autoChangeTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 80, contentView.frame.size.height*2/5)];
    [autoChangeTitle setText:@"自动调整"];
    autoChangeTitle.textAlignment = NSTextAlignmentCenter;
    [contentView addSubview:autoChangeTitle];
    
    UISwitch *enableAutoSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(contentView.frame.size.width-110, autoChangeTitle.frame.size.height/2 -20, 80, 40)];
    enableAutoSwitch.tintColor = [UIColor colorWithRed:0.39 green:0.39 blue:0.42 alpha:0.88];
    [enableAutoSwitch setCenter:CGPointMake(contentView.frame.size.width-70, autoChangeTitle.center.y)];
    [contentView addSubview:enableAutoSwitch];
    NSString *autoSwitchString = [[NSUserDefaults standardUserDefaults] objectForKey:AUTOSWITCH];
    if ([autoSwitchString isEqualToString:@"on"])
    {
        enableAutoSwitch.on = YES;
    }else
    {
        enableAutoSwitch.on = NO;
    }
    [enableAutoSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    
    UILabel *modelTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, contentView.frame.size.height*2/5, 80, contentView.frame.size.height*3/5)];
    [modelTitle setText:@"显示模式"];
    modelTitle.textAlignment = NSTextAlignmentCenter;
    [contentView addSubview:modelTitle];
    
    
    UIView *midline = [[UIView alloc] initWithFrame:CGRectMake(0, contentView.frame.size.height*2/5, contentView.frame.size.width, 0.65f)];
    midline.backgroundColor = [UIColor darkGrayColor];
    [contentView addSubview:midline];
    
    NSArray *timeTitle = @[@"早",@"午",@"夕",@"夜"];
    for (int i = 4; i>0; i--) {
        UIButton *timeButton = [[UIButton alloc] initWithFrame:CGRectMake(contentView.frame.size.width - 55 - (4-i) *(40+10), contentView.frame.size.height*2/5 + modelTitle.frame.size.height/2 - 20, 40, 40)];
        [timeButton setTitle:timeTitle[i - 1] forState:UIControlStateNormal];
        timeButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.5f];
        [timeButton setTitleColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.95] forState:UIControlStateNormal];
        timeButton.tag = i;
        [timeButton addTarget:self action:@selector(timeSelect:) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:timeButton];
        
        UIView *selectedBar = [[UIView alloc] initWithFrame:CGRectMake(0, timeButton.frame.size.height-3, timeButton.frame.size.width, 3)];
        selectedBar.backgroundColor = [UIColor colorWithRed:247/255.0f green:81/255.0f blue:94/255.0f alpha:0.9];
        selectedBar.tag = 10;
        [timeButton addSubview:selectedBar];
        [selectedBar setHidden:YES];
    }
    
    NSString *showModel =  [[NSUserDefaults standardUserDefaults] objectForKey:MODEL];
    for (int i = 0 ; i < 4; i++) {
        if ([showModel isEqualToString:timeTitle[i]])
        {
            UIButton *button = (UIButton *)[contentView viewWithTag:i+1];
            
            [button setTitleColor:[UIColor colorWithRed:247/255.0f green:81/255.0f blue:94/255.0f alpha:0.9]forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:19.0f];
            UIView *selectBar = (UIView *)[button viewWithTag:10];
            [selectBar setHidden:NO];
            break;
        }
    }


}


-(void)timeSelect:(UIButton *)sender
{
    for (int i =4 ; i>0; i--) {
        UIView *superView = sender.superview;
        UIButton *button = (UIButton *)[superView viewWithTag:i];
        [button setTitleColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.95] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.5f];
        UIView *selectBar = (UIView *)[button viewWithTag:10];
        [selectBar setHidden:YES];
        
    }
    
    [sender setTitleColor:[UIColor colorWithRed:247/255.0f green:81/255.0f blue:94/255.0f alpha:0.9]forState:UIControlStateNormal];
    sender.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:19.0f];
    UIView *selectBar = (UIView *)[sender viewWithTag:10];
    [selectBar setHidden:NO];
    
    NSArray *timeTitle = @[@"早",@"午",@"夕",@"夜"];
    
    [[NSUserDefaults standardUserDefaults] setObject:timeTitle[sender.tag - 1] forKey:MODEL];
    [[NSNotificationCenter defaultCenter] postNotificationName:ThemeChanged  object:nil];
    
    
}

-(void)switchAction:(UISwitch *)sender
{
    if (sender.on) {
        [[NSUserDefaults standardUserDefaults] setObject:@"on" forKey:AUTOSWITCH];
    }else
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"off" forKey:AUTOSWITCH];
    }
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate judgeTimeFrame];
    
    NSString *showModel =  [[NSUserDefaults standardUserDefaults] objectForKey:MODEL];
    NSArray *timeTitle = @[@"早",@"午",@"夕",@"夜"];
    UIView *contentView = [self.myDimView viewWithTag:100];
    
    //还原未选状态
    for (int i =4 ; i>0; i--) {
        UIView *superView = sender.superview;
        UIButton *button = (UIButton *)[superView viewWithTag:i];
        [button setTitleColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.95] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.5f];
        UIView *selectBar = (UIView *)[button viewWithTag:10];
        [selectBar setHidden:YES];
        
    }
//选择一个模式
    for (int i = 0 ; i < 4; i++) {
        if ([showModel isEqualToString:timeTitle[i]])
        {
            UIButton *button = (UIButton *)[contentView viewWithTag:i+1];
            
            [button setTitleColor:[UIColor colorWithRed:247/255.0f green:81/255.0f blue:94/255.0f alpha:0.9]forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:19.0f];
            UIView *selectBar = (UIView *)[button viewWithTag:10];
            [selectBar setHidden:NO];
            break;
        }
    }

}

-(void)dismissKeyboard
{
    UIView *contentView = [self.myDimView viewWithTag:100];
    [UIView animateWithDuration:0.32f animations:^{
        if (contentView) {
            [contentView setFrame:CGRectMake(contentView.frame.origin.x, SCREEN_HEIGHT, contentView.frame.size.width, contentView.frame.size.height)];
        }
    } completion:^(BOOL isfinished){
        [self.myDimView removeFromSuperview];
    }];
}

-(void)dealloc
{
    [self.maintableView removeObserver:self forKeyPath: @"contentOffset" context:nil];
}

#pragma baseVC overwrite

@end
