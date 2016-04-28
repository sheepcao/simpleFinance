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
}
@property (nonatomic,strong) NSString *startDate;
@property (nonatomic,strong) NSString *endDate;
@property (nonatomic,strong) UILabel *dateRangeLabel;

@property (strong, nonatomic)  UITableView *maintableView;
@property (nonatomic,strong) FMDatabase *db;
@property (nonatomic,strong) PNLineChart *mylineChart;

@end

@implementation trendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSDate * todayDate = [NSDate date];
    weekStart = [[CommonUtility sharedCommonUtility] weekStartDayOf:todayDate];
    weekEnd = [[CommonUtility sharedCommonUtility] weekEndDayOf:todayDate];
    weekSequence = [[CommonUtility sharedCommonUtility] weekSequence:todayDate];
    


    [self configTopbar];
    [self configTable];
    [self configLineChartAxis];
    [self configLineChart];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
    timeSeg.selectedSegmentIndex = 0;
    [timeSeg addTarget:self action:@selector(segmentAction:)forControlEvents:UIControlEventValueChanged];  //添加委托方法
    [topbar addSubview:timeSeg];
    
    self.startDate = [[CommonUtility sharedCommonUtility] yesterdayDate];
    self.endDate = [[CommonUtility sharedCommonUtility] dateByAddingDays:self.startDate andDaysToAdd:1];
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
    
    currentIndexPath = [[NSIndexPath alloc] initWithIndex:0];
    
    [self.view addSubview:self.maintableView];
    [self.view bringSubviewToFront:self.maintableView];
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
            break;
        case 1://上周
            self.endDate = [[CommonUtility sharedCommonUtility] dateByAddingDays:weekStart andDaysToAdd:-1];
            self.startDate = [[CommonUtility sharedCommonUtility] dateByAddingDays:weekStart andDaysToAdd:-7];
            break;
        case 2://上2周
            self.endDate = [[CommonUtility sharedCommonUtility] dateByAddingDays:weekStart andDaysToAdd:-1];
            self.startDate = [[CommonUtility sharedCommonUtility] dateByAddingDays:weekStart andDaysToAdd:-14];
            break;
        case 3://上4周
            self.endDate = [[CommonUtility sharedCommonUtility] dateByAddingDays:weekStart andDaysToAdd:-1];
            self.startDate = [[CommonUtility sharedCommonUtility] dateByAddingDays:weekStart andDaysToAdd:-28];
        
            break;
        case 4://上13周
            self.endDate = [[CommonUtility sharedCommonUtility] dateByAddingDays:weekStart andDaysToAdd:-1];
            self.startDate = [[CommonUtility sharedCommonUtility] dateByAddingDays:weekStart andDaysToAdd:-91];
            break;
    
        default:
            break;
    }
    
    if (Seg.selectedSegmentIndex == 0) {
        [self.dateRangeLabel setText:self.startDate];
    }else
    {
        NSString *dateRange = [NSString stringWithFormat:@"%@ - %@",self.startDate,self.endDate];
        [self.dateRangeLabel setText:dateRange];
        
    }
    
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
    }
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[trendTableViewCell class]]) {
        trendTableViewCell *itemCell = (trendTableViewCell *)cell;
        [itemCell.category setTextColor:[UIColor colorWithRed:1.0f green:0.65f blue:0.0f alpha:1.0f]];
    }
    currentIndexPath = indexPath;
    
}

#pragma mark -
#pragma mark Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
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
    
    return 2;
}

- (trendTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *CellIdentifier = @"trendCell";
    
    trendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[trendTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
    }
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (![scrollView isKindOfClass:[UITableView class]]) {

        
    }else
    {
        
        for (UITableViewCell *cell in self.maintableView.visibleCells) {
            trendTableViewCell *oneCell = (trendTableViewCell *)cell;
            CGFloat hiddenFrameHeight = scrollView.contentOffset.y - cell.frame.origin.y;
            if (hiddenFrameHeight >= 0 || hiddenFrameHeight <= cell.frame.size.height) {
                [oneCell maskCellFromTop:hiddenFrameHeight];
            }
        }
    }
}


@end
