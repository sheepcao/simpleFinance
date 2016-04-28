//
//  trendViewController.m
//  simpleFinance
//
//  Created by Eric Cao on 4/27/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "trendViewController.h"
#import "topBarView.h"
#import "global.h"
#import "CommonUtility.h"
#import "trendTableViewCell.h"
#import "PNChart.h"


@interface trendViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>
{
    NSIndexPath *currentIndexPath;
    NSString *weekStart;
    NSString *weekEnd;
    NSInteger weekSequence;
    NSInteger daysOffsite;
    NSInteger dataType;  // 0---money,1---increase,2---ratio
    NSInteger sectionCount;
}
@property (nonatomic,strong) NSString *startDate;
@property (nonatomic,strong) NSString *endDate;
@property (nonatomic,strong) UILabel *dateRangeLabel;

@property (strong, nonatomic)  UITableView *maintableView;
@property (nonatomic,strong) FMDatabase *db;
@property (nonatomic,strong) PNLineChart *mylineChart;
@property (nonatomic,strong) UIScrollView *mychartScroll;
@property (nonatomic,strong) NSMutableArray *totalDataArray;
@property (nonatomic,strong) NSMutableArray *incomeDataArray;
@property (nonatomic,strong) NSMutableArray *expenseDataArray;


@end

@implementation trendViewController
@synthesize db;

- (void)viewDidLoad {
    [super viewDidLoad];
    NSDate * todayDate = [NSDate date];
    weekStart = [[CommonUtility sharedCommonUtility] weekStartDayOf:todayDate];
    weekEnd = [[CommonUtility sharedCommonUtility] weekEndDayOf:todayDate];
    weekSequence = [[CommonUtility sharedCommonUtility] weekSequence:todayDate];
    
    dataType = 0;
    sectionCount = 0;
    
    [self configTopbar];
    [self configTable];
    [self configLineChartAxis];
    [self configLineChart];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)refreshDataFrom:(NSString *)startDate andEndDay:(NSString *)endDate
{
    self.totalDataArray = [[NSMutableArray alloc] init];
    self.incomeDataArray = [[NSMutableArray alloc] init];
    self.expenseDataArray = [[NSMutableArray alloc] init];
    
    NSString *nextEndDay = [[CommonUtility sharedCommonUtility] dateByAddingDays:endDate andDaysToAdd:1];
    
    NSString *lastStartDate = [[CommonUtility sharedCommonUtility] dateByAddingDays:startDate andDaysToAdd:daysOffsite];
    NSString *lastnextEndDay = [[CommonUtility sharedCommonUtility] dateByAddingDays:nextEndDay andDaysToAdd:daysOffsite];
    
    
    db = [[CommonUtility sharedCommonUtility] db];
    if (![db open]) {
        NSLog(@"mainVC/Could not open db.");
        return;
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //for total numbers....
    
    for (int i = 1 ; i>=0; i--) {
        NSMutableArray *moneyTotalsArray = [[NSMutableArray alloc] initWithCapacity:4];
        (i == 1)?[moneyTotalsArray addObject:@"收入"] : [moneyTotalsArray addObject:@"支出"];
        FMResultSet *resultMoney = [db executeQuery:@"select sum(money) from ITEMINFO where strftime('%s', create_time) BETWEEN strftime('%s', ?) AND strftime('%s', ?) AND item_type = ?", startDate,nextEndDay,[NSNumber numberWithInt:i]];
        if ([resultMoney next]) {
            double totalIncome =  [resultMoney doubleForColumnIndex:0];
            [moneyTotalsArray addObject:[NSString stringWithFormat:@"%.2f",totalIncome]];
        }
        FMResultSet *lastResultMoney = [db executeQuery:@"select sum(money) from ITEMINFO where strftime('%s', create_time) BETWEEN strftime('%s', ?) AND strftime('%s', ?) AND item_type = ?", lastStartDate,lastnextEndDay,[NSNumber numberWithInt:i]];
        if ([lastResultMoney next]) {
            double lastTotalIncome =  [lastResultMoney doubleForColumnIndex:0];
            double totalIncome = [moneyTotalsArray[1] doubleValue];
            double compareIncome = totalIncome - lastTotalIncome;
            if (compareIncome>0.001) {
                [moneyTotalsArray addObject:[NSString stringWithFormat:@"+%.2f",compareIncome]];
                if (lastTotalIncome <0.001) {
                    [moneyTotalsArray addObject:@"+100%"];
                }else
                {
                    [moneyTotalsArray addObject:[NSString stringWithFormat:@"+%.2f%%",compareIncome*100/lastTotalIncome]];
                }
            }else
            {
                [moneyTotalsArray addObject:[NSString stringWithFormat:@"%.2f",compareIncome]];
                if (lastTotalIncome <0.001) {
                    [moneyTotalsArray addObject:@"0%"];
                }else
                {
                    [moneyTotalsArray addObject:[NSString stringWithFormat:@"%.2f%%",compareIncome*100/lastTotalIncome]];
                }
            }
        }
        [self.totalDataArray addObject:moneyTotalsArray];
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //for category numbers....
    
    for (int i = 1; i>=0; i--) {
        
        NSMutableArray *allCategories = [[NSMutableArray alloc] init];
        FMResultSet *rs = [db executeQuery:@"select distinct item_category from ITEMINFO where strftime('%s', create_time) BETWEEN strftime('%s', ?) AND strftime('%s', ?) AND item_type = ?", lastStartDate,nextEndDay,[NSNumber numberWithInt:i]];
        while ([rs next]) {
            NSString *categoryName = [rs stringForColumn:@"item_category"];
            [allCategories addObject:categoryName];
        }
        
        for (NSString *oneCategory in allCategories) {
            NSMutableArray *moneyTotalsArray = [[NSMutableArray alloc] initWithCapacity:4];
            [moneyTotalsArray addObject:oneCategory];
            
            FMResultSet *resultMoney = [db executeQuery:@"select sum(money) from ITEMINFO where strftime('%s', create_time) BETWEEN strftime('%s', ?) AND strftime('%s', ?) AND item_type = ? AND item_category = ? ", startDate,nextEndDay,[NSNumber numberWithInt:i],oneCategory];
            if ([resultMoney next]) {
                double totalMoney =  [resultMoney doubleForColumnIndex:0];
                [moneyTotalsArray addObject:[NSString stringWithFormat:@"%.2f",totalMoney]];
            }
            
            FMResultSet *lastResultMoney = [db executeQuery:@"select sum(money) from ITEMINFO where strftime('%s', create_time) BETWEEN strftime('%s', ?) AND strftime('%s', ?) AND item_type = ?  AND item_category = ? ", lastStartDate,lastnextEndDay,[NSNumber numberWithInt:i],oneCategory];
            if ([lastResultMoney next]) {
                double lastTotalIncome =  [lastResultMoney doubleForColumnIndex:0];
                double totalIncome = [moneyTotalsArray[1] doubleValue];
                double compareIncome = totalIncome - lastTotalIncome;
                if (compareIncome>0.001) {
                    [moneyTotalsArray addObject:[NSString stringWithFormat:@"+%.2f",compareIncome]];
                    if (lastTotalIncome <0.001) {
                        [moneyTotalsArray addObject:@"+100%"];
                    }else
                    {
                        [moneyTotalsArray addObject:[NSString stringWithFormat:@"+%.2f%%",compareIncome*100/lastTotalIncome]];
                    }
                }else
                {
                    [moneyTotalsArray addObject:[NSString stringWithFormat:@"%.2f",compareIncome]];
                    if (lastTotalIncome <0.001) {
                        [moneyTotalsArray addObject:@"0%"];
                    }else
                    {
                        [moneyTotalsArray addObject:[NSString stringWithFormat:@"%.2f%%",compareIncome*100/lastTotalIncome]];
                    }
                }
            }
            (i == 1)? [self.incomeDataArray addObject:moneyTotalsArray] : [self.expenseDataArray addObject:moneyTotalsArray];
        }
    }
    
    [db close];
    [UIView transitionWithView: self.maintableView
                      duration: 0.35f
                       options: UIViewAnimationOptionTransitionCrossDissolve
                    animations: ^(void)
     {
         [self.maintableView reloadData];
     }
                    completion: nil];

    
    [self tableView:self.maintableView didSelectRowAtIndexPath:currentIndexPath];
}


-(void)configTopbar
{
    topBarView *topbar = [[topBarView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, topRowHeight + 5)];
    topbar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:topbar];
    
    
    UIButton *saveButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 32, 60, 40)];
    saveButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    saveButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [saveButton setTitle:@"返回" forState:UIControlStateNormal];
    [saveButton setTitleColor:   [UIColor colorWithRed:76/255.0f green:101/255.0f blue:120/255.0f alpha:1.0f]forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    saveButton.backgroundColor = [UIColor clearColor];
    [topbar addSubview:saveButton];
    
    NSArray *segmentedArray = [[NSArray alloc]initWithObjects:@"1天",@"1周",@"2周",@"4周",@"13周",nil];
    UISegmentedControl *timeSeg = [[UISegmentedControl alloc]initWithItems:segmentedArray];
    timeSeg.frame = CGRectMake(SCREEN_WIDTH*0.18, 35, SCREEN_WIDTH*0.64, 30);
    timeSeg.tintColor =  [UIColor colorWithRed:76/255.0f green:101/255.0f blue:120/255.0f alpha:1.0f];
    timeSeg.selectedSegmentIndex = 1;
    [timeSeg addTarget:self action:@selector(segmentAction:)forControlEvents:UIControlEventValueChanged];  //添加委托方法
    [topbar addSubview:timeSeg];
    
    self.endDate = [[CommonUtility sharedCommonUtility] dateByAddingDays:weekStart andDaysToAdd:-1];
    self.startDate = [[CommonUtility sharedCommonUtility] dateByAddingDays:weekStart andDaysToAdd:-7];
    daysOffsite = -7;
    
    self.dateRangeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, topbar.frame.size.height + 2, SCREEN_WIDTH, 40)];
    self.dateRangeLabel.backgroundColor = [UIColor clearColor];
    [self.dateRangeLabel setTextColor:TextColor];
    [self.dateRangeLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:SCREEN_WIDTH/23]];
    
    self.dateRangeLabel.textAlignment = NSTextAlignmentCenter;
    [self.dateRangeLabel setText:self.startDate];
    [self.view addSubview:self.dateRangeLabel];
    
    
    
}


-(void)configTable
{
    CGFloat tableY = self.dateRangeLabel.frame.origin.y+self.dateRangeLabel.frame.size.height;
    self.maintableView = [[UITableView alloc] initWithFrame:CGRectMake(0, tableY ,SCREEN_WIDTH,SCREEN_HEIGHT- SCREEN_WIDTH/2 -tableY) style:UITableViewStylePlain];
    self.maintableView.showsVerticalScrollIndicator = NO;
    self.maintableView.backgroundColor = [UIColor clearColor];
    self.maintableView.delegate = self;
    self.maintableView.dataSource = self;
    self.maintableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.maintableView.canCancelContentTouches = YES;
    self.maintableView.delaysContentTouches = YES;
    
    [self.view addSubview:self.maintableView];
    [self.view bringSubviewToFront:self.maintableView];
    currentIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self refreshDataFrom:self.startDate andEndDay:self.endDate];
    
}

-(void)configLineChart
{
    CGFloat tableY = self.maintableView.frame.origin.y+self.maintableView.frame.size.height;
    
    PNLineChart * lineChart = [[PNLineChart alloc] initWithFrame:CGRectMake(0, 0, 800, SCREEN_WIDTH/2)];
    lineChart.chartMarginLeft = 0;
    lineChart.backgroundColor = [UIColor clearColor];
    lineChart.yLabelColor = [UIColor clearColor];
    lineChart.xLabelColor = PNLightGrey;
    
    [lineChart setXLabels:@[@"SEP 1",@"SEP 2",@"SEP 3",@"SEP 4",@"SEP 5",@"SEP 6",@"SEP 7",@"SEP 2",@"SEP 3",@"SEP 4",@"SEP 5",@"SEP 6",@"SEP 7",@"SEP 2",@"SEP 3",@"SEP 4",@"SEP 5",@"SEP 6",@"SEP 7"]];
    
    UIScrollView *chartScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(35, tableY, SCREEN_WIDTH-40, SCREEN_WIDTH/2)];
    self.mychartScroll = chartScroll;
    chartScroll.contentSize = CGSizeMake(800, chartScroll.frame.size.height);
    chartScroll.delegate = self;
    chartScroll.showsHorizontalScrollIndicator = NO;
    [chartScroll addObserver: self forKeyPath: @"contentOffset" options: NSKeyValueObservingOptionNew context: nil];
    
    // Line Chart No.1
    NSArray * data01Array = @[@60.1, @160.1, @126.4, @262.2, @186.2,@111.1,@332, @160.1, @126.4, @262.2, @186.2,@111.1,@332, @160.1, @126.4, @262.2, @186.2,@111.1,@332];
    PNLineChartData *data01 = [PNLineChartData new];
    data01.inflexionPointStyle = PNLineChartPointStyleCircle;
    data01.color = PNCleanGrey;
    data01.lineWidth = 1.6f;
    data01.itemCount = lineChart.xLabels.count;
    data01.getData = ^(NSUInteger index) {
        CGFloat yValue = [data01Array[index] floatValue];
        return [PNLineChartDataItem dataItemWithY:yValue];
    };
    lineChart.chartData = @[data01];
    lineChart.showLabel = YES;
    lineChart.showCoordinateAxis = NO;
    lineChart.showAxisX = YES;
    
    lineChart.axisColor = PNLightGrey;
    lineChart.axisWidth = 1.0f;
    
    [lineChart strokeChart];
    
    [chartScroll addSubview:lineChart];
    [self.view addSubview:chartScroll];
    
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    UIScrollView * scrollView = (UIScrollView *)object;
    
    if (scrollView.contentOffset.x < -0.00001)
    {
        [scrollView setContentOffset:CGPointMake(0, 0)];
    }
}

-(void)configLineChartAxis
{
    CGFloat tableY = self.maintableView.frame.origin.y+self.maintableView.frame.size.height;
    
    PNLineChart * lineChart = [[PNLineChart alloc] initWithFrame:CGRectMake(0, tableY, 800, SCREEN_WIDTH/2)];
    lineChart.backgroundColor = [UIColor clearColor];
    lineChart.chartMarginTop = 10;
    lineChart.yLabelColor = PNLightGrey;
    lineChart.xLabelColor = [UIColor clearColor];
    [lineChart setXLabels:@[@"SEP 1",@"SEP 2",@"SEP 3",@"SEP 4",@"SEP 5",@"SEP 6",@"SEP 7",@"SEP 2",@"SEP 3",@"SEP 4",@"SEP 5",@"SEP 6",@"SEP 7",@"SEP 2",@"SEP 3",@"SEP 4",@"SEP 5",@"SEP 6",@"SEP 7"]];
    
    
    // Line Chart No.1
    NSArray * data01Array = @[@60.1, @160.1, @126.4, @262.2, @186.2,@111.1,@332, @160.1, @126.4, @262.2, @186.2,@111.1,@332, @160.1, @126.4, @262.2, @186.2,@111.1,@332];
    PNLineChartData *data01 = [PNLineChartData new];
    data01.inflexionPointStyle = PNLineChartPointStyleCircle;
    data01.color = PNCleanGrey;
    data01.lineWidth = 1.6f;
    data01.itemCount = lineChart.xLabels.count;
    data01.getData = ^(NSUInteger index) {
        CGFloat yValue = [data01Array[index] floatValue];
        return [PNLineChartDataItem dataItemWithY:yValue];
    };
    lineChart.chartData = @[data01];
    lineChart.showCoordinateAxis = NO;
    lineChart.showAxisY = YES;
    lineChart.axisColor = PNLightGrey;
    lineChart.axisWidth = 1.0f;
    
    [self.view addSubview:lineChart];
    
}

-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)segmentAction:(UISegmentedControl *)Seg{
    NSInteger Index = Seg.selectedSegmentIndex;
    NSLog(@"Index %ld", (long)Index);
    //    NSString *today = [[CommonUtility sharedCommonUtility] todayDate];
    
    
    switch (Seg.selectedSegmentIndex) {
        case 0:
            self.endDate = [[CommonUtility sharedCommonUtility] yesterdayDate];
            self.startDate = [[CommonUtility sharedCommonUtility] yesterdayDate];
            daysOffsite = -1;
            break;
        case 1://上周
            self.endDate = [[CommonUtility sharedCommonUtility] dateByAddingDays:weekStart andDaysToAdd:-1];
            self.startDate = [[CommonUtility sharedCommonUtility] dateByAddingDays:weekStart andDaysToAdd:-7];
            daysOffsite = -7;
            break;
        case 2://上2周
            self.endDate = [[CommonUtility sharedCommonUtility] dateByAddingDays:weekStart andDaysToAdd:-1];
            self.startDate = [[CommonUtility sharedCommonUtility] dateByAddingDays:weekStart andDaysToAdd:-14];
            daysOffsite = -14;
            break;
        case 3://上4周
            self.endDate = [[CommonUtility sharedCommonUtility] dateByAddingDays:weekStart andDaysToAdd:-1];
            self.startDate = [[CommonUtility sharedCommonUtility] dateByAddingDays:weekStart andDaysToAdd:-28];
            daysOffsite = -28;
            
            break;
        case 4://上13周
            self.endDate = [[CommonUtility sharedCommonUtility] dateByAddingDays:weekStart andDaysToAdd:-1];
            self.startDate = [[CommonUtility sharedCommonUtility] dateByAddingDays:weekStart andDaysToAdd:-91];
            daysOffsite = -91;
            break;
            
        default:
            break;
    }
    
    if (Seg.selectedSegmentIndex == 0) {
        [self.dateRangeLabel setText:self.startDate];
    }else
    {
        NSString *dateRange = [NSString stringWithFormat:@"%@  到  %@",self.startDate,self.endDate];
        [self.dateRangeLabel setText:dateRange];
        
    }
    
    [self refreshDataFrom:self.startDate andEndDay:self.endDate];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark -
#pragma mark Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"heightForRowAtIndexPath");
    return SCREEN_WIDTH/9;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return SCREEN_WIDTH/16;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelectRowAtIndexPath");
    
    UITableViewCell *cellbefore = [tableView cellForRowAtIndexPath:currentIndexPath];
    if ([cellbefore isKindOfClass:[trendTableViewCell class]]) {
        trendTableViewCell *itemCell = (trendTableViewCell *)cellbefore;
        [itemCell.category setTextColor:TextColor];
        [itemCell.seperator setHidden:YES];
    }
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[trendTableViewCell class]]) {
        trendTableViewCell *itemCell = (trendTableViewCell *)cell;
        [itemCell.category setTextColor:[UIColor colorWithRed:1.0f green:0.65f blue:0.0f alpha:1.0f]];
        [itemCell.seperator setHidden:NO];
    }
    currentIndexPath = indexPath;
    
}

#pragma mark -
#pragma mark Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int i = 0;
    if (self.totalDataArray.count>0) {
        i++;
    }
    if (self.incomeDataArray.count>0) {
        i++;
    }
    if (self.expenseDataArray.count>0) {
        i++;
    }
    sectionCount = i;
    return sectionCount;
}
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, SCREEN_WIDTH/16)];
    headerView.backgroundColor = [UIColor clearColor];
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, headerView.frame.size.height - 18, 160, 18)];
    dateLabel.textAlignment = NSTextAlignmentLeft;
    dateLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:SCREEN_WIDTH/28];
    dateLabel.textColor = [UIColor colorWithRed:253/255.0f green:197/255.0f blue:65/255.0f alpha:1.0f];
    [headerView addSubview:dateLabel];
    switch (section) {
        case 0:
            [dateLabel setText:@"收支总览"];
            break;
        case 1:
            [dateLabel setText:@"收入明细"];
            break;
        case 2:
            [dateLabel setText:@"支出明细"];
            break;
            
        default:
            break;
    }
    return headerView;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0 )
    {
        return self.totalDataArray.count;
    }else if (section == 1)
    {
        return self.incomeDataArray.count;
    }else
    {
        return self.expenseDataArray.count;
    }
}

- (trendTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *CellIdentifier = @"trendCell";
    
    trendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[trendTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        [cell.money addTarget:self action:@selector(dataTypeChanged:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    NSArray *dataArray ;
    
    if (indexPath.section == 0) {
        dataArray = [NSArray arrayWithArray:self.totalDataArray];
    }else if(indexPath.section == 1)
    {
        dataArray = [NSArray arrayWithArray:self.incomeDataArray];
    }else if(indexPath.section == 2)
    {
        dataArray = [NSArray arrayWithArray:self.expenseDataArray];
    }
    
    NSArray *oneRowData = [dataArray objectAtIndex:indexPath.row];
    
    if (oneRowData.count>3) {
        [cell.category setText:oneRowData[0]];
        NSString *money = [NSString stringWithFormat:@"%@",oneRowData[dataType + 1]];
        money = [money componentsSeparatedByString:@".00"][0];
        [cell.money setTitle:money forState:UIControlStateNormal];
        [cell makeTextColorForIncrease:oneRowData[3]];
    }
    
    return cell;
}

-(void)dataTypeChanged:(UIButton *)sender
{
    dataType ++;
    dataType = dataType%3;
    [UIView transitionWithView: self.maintableView
                      duration: 0.45f
                       options: UIViewAnimationOptionTransitionCrossDissolve
                    animations: ^(void)
     {
         [self.maintableView reloadData];
     }
                    completion: nil];

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (![scrollView isKindOfClass:[UITableView class]]) {
    }else
    {
        
        for (UITableViewCell *cell in self.maintableView.visibleCells) {
            trendTableViewCell *oneCell = (trendTableViewCell *)cell;
            CGFloat hiddenFrameHeight = scrollView.contentOffset.y + [self tableView:self.maintableView heightForHeaderInSection:0]- cell.frame.origin.y;
            if (hiddenFrameHeight >= 0 || hiddenFrameHeight <= cell.frame.size.height) {
                [oneCell maskCellFromTop:hiddenFrameHeight];
            }
        }
    }
}

-(void)dealloc
{
    [self.mychartScroll removeObserver:self forKeyPath:@"contentOffset" context:nil];
}

@end
