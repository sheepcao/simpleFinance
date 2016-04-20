//
//  pieViewController.m
//  simpleFinance
//
//  Created by Eric Cao on 4/20/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "pieViewController.h"
#import "global.h"
#import "topBarView.h"
#import "PNChart.h"
#import "CommonUtility.h"
#import "itemObj.h"
#import "PieExplainTableViewCell.h"

@interface pieViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic ,strong) UISegmentedControl *moneyTypeSeg;
@property (nonatomic, strong) PNPieChart *pieChart;
@property (nonatomic,strong) UILabel *centerLabel;
@property (nonatomic,strong) NSMutableArray *timeWindowItems;
@property (nonatomic,strong) NSArray *timeWindowCategories;
@property (nonatomic,strong) FMDatabase *db;
@property (nonatomic,strong) UIView *myPieView;
@property double sumIncome;
@property double sumExpense;

@property (nonatomic,strong) UITableView *detailTable;


@end

@implementation pieViewController
@synthesize db;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSString *startDay = [[CommonUtility sharedCommonUtility] firstMonthDate];
    //    NSString *nextEndDay = [[CommonUtility sharedCommonUtility] firstNextMonthDate];
    //    NSString *endDay = [[CommonUtility sharedCommonUtility] lastMonthDate];
    NSString *endDay = @"2016-04-20";
    NSString *nextEndDay = [[CommonUtility sharedCommonUtility] dateByAddingDays:endDay andDaysToAdd:1];
    [self prepareDataFrom:startDay toDate:nextEndDay];
    [self configTopbar];
    [self configPieWithStartDate:startDay AndEndDate:endDay];
    [self configDetailTable];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareDataFrom:(NSString *)startDate toDate:(NSString *)endDate
{
    self.timeWindowItems = [[NSMutableArray alloc] init];
    self.timeWindowCategories = [[NSArray alloc] init];
    
    db = [[CommonUtility sharedCommonUtility] db];
    if (![db open]) {
        NSLog(@"mainVC/Could not open db.");
        return;
    }
    
    FMResultSet *rs = [db executeQuery:@"select * from ITEMINFO where strftime('%s', create_time) BETWEEN strftime('%s', ?) AND strftime('%s', ?)", startDate,endDate];
    
    while ([rs next]) {
        itemObj *oneItem = [[itemObj alloc] init];
        oneItem.itemID = [NSNumber numberWithInt: [rs intForColumn:@"item_id"]];
        oneItem.itemCategory  = [rs stringForColumn:@"item_category"];
        oneItem.itemDescription = [rs stringForColumn:@"item_description"];
        oneItem.itemType = [rs intForColumn:@"item_type"];
        oneItem.createdTime = [rs stringForColumn:@"create_time"];
        oneItem.moneyAmount = [rs doubleForColumn:@"money"];
        [self.timeWindowItems addObject:oneItem];
    }
    //
    FMResultSet *resultIncome = [db executeQuery:@"select sum(money) from ITEMINFO where strftime('%s', create_time) BETWEEN strftime('%s', ?) AND strftime('%s', ?) AND item_type = 1", startDate,endDate];
    if ([resultIncome next]) {
        self.sumIncome =  [resultIncome doubleForColumnIndex:0];
    }
    
    FMResultSet *resultExpense = [db executeQuery:@"select sum(money) from ITEMINFO where strftime('%s', create_time) BETWEEN strftime('%s', ?) AND strftime('%s', ?) AND item_type = 0", startDate,endDate];
    
    if ([resultExpense next]) {
        self.sumExpense =  [resultExpense doubleForColumnIndex:0];
    }
    [db close];
    
}

-(NSMutableArray *)makePieData:(NSInteger)isIncome
{
    self.sumIncome = 0.0;
    self.sumExpense = 0.0;
    
    NSMutableArray *itemsArray = [[NSMutableArray alloc] init];
    NSMutableDictionary *itemDic = [[NSMutableDictionary alloc] init];
    
    if (isIncome) {
        for (itemObj *item in self.timeWindowItems) {
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
        for (itemObj *item in self.timeWindowItems) {
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




-(void)configTopbar
{
    topBarView *topbar = [[topBarView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, topRowHeight)];
    topbar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:topbar];
    
    
    UIButton *saveButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 27, 60, 40)];
    saveButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    saveButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [saveButton setTitle:@"返回" forState:UIControlStateNormal];
    [saveButton setTitleColor:   [UIColor colorWithRed:76/255.0f green:101/255.0f blue:120/255.0f alpha:1.0f]forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    saveButton.backgroundColor = [UIColor clearColor];
    [topbar addSubview:saveButton];
    
    NSArray *segmentedArray = [[NSArray alloc]initWithObjects:@"支出",@"收入",nil];
    self.moneyTypeSeg = [[UISegmentedControl alloc]initWithItems:segmentedArray];
    self.moneyTypeSeg.frame = CGRectMake(SCREEN_WIDTH*2/7, 30, SCREEN_WIDTH*3/7, 30);
    self.moneyTypeSeg.tintColor =  [UIColor colorWithRed:76/255.0f green:101/255.0f blue:120/255.0f alpha:1.0f];
    self.moneyTypeSeg.selectedSegmentIndex = 0;
    [self.moneyTypeSeg addTarget:self action:@selector(segmentAction:)forControlEvents:UIControlEventValueChanged];  //添加委托方法
    [topbar addSubview:self.moneyTypeSeg];
    
}

-(void)configPieWithStartDate:(NSString *)startDate AndEndDate:(NSString *)endDate
{
    UIView *pieView = [[UIView alloc] initWithFrame:CGRectMake(0, topRowHeight, SCREEN_WIDTH, SCREEN_WIDTH)];
    pieView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:pieView];
    self.myPieView = pieView;
    
    //add date selection ======================================================
    UIButton *dateSelectionView = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/5, 5, SCREEN_WIDTH*3/5, SCREEN_WIDTH*0.15)];
    dateSelectionView.backgroundColor = [UIColor clearColor];
    [pieView addSubview:dateSelectionView];
    UIFontDescriptor *attributeFontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                                 @{UIFontDescriptorFamilyAttribute: @"Source Han Sans CN",
                                                   UIFontDescriptorNameAttribute:@"SourceHanSansCN-Normal",
                                                   UIFontDescriptorSizeAttribute: [NSNumber numberWithFloat:  14.0f]
                                                   }];
    UILabel * midLine = [[UILabel alloc] initWithFrame:CGRectMake(dateSelectionView.frame.size.width/2-15, 0, 30, dateSelectionView.frame.size.height)];
    [midLine setText:@"至"];
    midLine.textAlignment = NSTextAlignmentCenter;
    [midLine setTextColor:TextColor];
    [midLine setFont:[UIFont fontWithDescriptor:attributeFontDescriptor size:0.0f]];
    [midLine setBackgroundColor:[UIColor clearColor]];
    [dateSelectionView addSubview:midLine];
    
    UILabel * startDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, (dateSelectionView.frame.size.width - midLine.frame.size.width)/2, dateSelectionView.frame.size.height)];
    startDateLabel.textAlignment = NSTextAlignmentRight;
    [startDateLabel setTextColor:[UIColor colorWithRed:253/255.0f green:197/255.0f blue:65/255.0f alpha:1.0f]];
    [startDateLabel setFont:[UIFont fontWithDescriptor:attributeFontDescriptor size:0.0f]];
    [startDateLabel setText:startDate];
    
    UILabel * endDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(startDateLabel.frame.size.width + midLine.frame.size.width, 0, startDateLabel.frame.size.width, dateSelectionView.frame.size.height)];
    endDateLabel.textAlignment = NSTextAlignmentLeft;
    [endDateLabel setTextColor:[UIColor colorWithRed:253/255.0f green:197/255.0f blue:65/255.0f alpha:1.0f]];
    [endDateLabel setFont:[UIFont fontWithDescriptor:attributeFontDescriptor size:0.0f]];
    [endDateLabel setText:endDate];
    
    
    [dateSelectionView addSubview:startDateLabel];
    [dateSelectionView addSubview:endDateLabel];
    
    // add pie===============================================================================
    
    self.timeWindowCategories = [self makePieData:0];
    NSArray *items = self.timeWindowCategories;
    self.pieChart = [[PNPieChart alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-SCREEN_WIDTH*3/8, dateSelectionView.frame.size.height + dateSelectionView.frame.origin.y + 10, SCREEN_WIDTH *3/4, SCREEN_WIDTH *3/4) items:items];
    self.pieChart.descriptionTextColor = [UIColor whiteColor];
    self.pieChart.descriptionTextFont  = [UIFont fontWithName:@"Avenir-Medium" size:13.0];
    [self.pieChart strokeChart];
    self.pieChart.displayAnimated = YES;
    self.pieChart.shouldHighlightSectorOnTouch = NO;
    self.pieChart.userInteractionEnabled = NO;
    self.pieChart.labelPercentageCutoff = 0.08;
    self.pieChart.duration = 0.65f;
    self.pieChart.hideValues = NO;
    self.pieChart.hasLegend = YES;
    [pieView addSubview:self.pieChart];
    
    self.centerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.pieChart.innerCircleRadius*2, self.pieChart.innerCircleRadius*2)];
    [self.centerLabel setCenter:CGPointMake(self.pieChart.center.x, self.pieChart.center.y)];
    self.centerLabel.layer.borderWidth = 0.8f;
    self.centerLabel.layer.borderColor = [UIColor colorWithRed:0.88f green:0.88f blue:0.88f alpha:1.0f].CGColor;
    self.centerLabel.backgroundColor = [UIColor colorWithRed:26/255.0f green:130/255.0f blue:194/255.0f alpha:1.0f];
    self.centerLabel.numberOfLines = 2;
    
    self.centerLabel.layer.cornerRadius = self.centerLabel.frame.size.width/2;
    self.centerLabel.layer.masksToBounds = YES;
    self.centerLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    self.centerLabel.layer.shadowOpacity = 1.0;
    self.centerLabel.layer.shadowRadius = 1.5f;
    self.centerLabel.layer.shadowOffset = CGSizeMake(0.0f, 1.5f);
    self.centerLabel.layer.shadowColor =  [UIColor blackColor].CGColor;
    self.centerLabel.layer.shadowOffset = CGSizeMake(0.0f, 0.5f);
    [pieView addSubview:self.centerLabel];
    
    [self makeMidText:self.moneyTypeSeg.selectedSegmentIndex ByMoney: [NSString stringWithFormat:@"%.0f",self.sumExpense]];
    
}

-(void)makeMidText:(NSInteger)isShowOutcome ByMoney:(NSString *)money
{
    NSMutableAttributedString* attrString;
    UIFontDescriptor *attributeFontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                                 @{UIFontDescriptorFamilyAttribute: @"Source Han Sans CN",
                                                   UIFontDescriptorNameAttribute:@"SourceHanSansCN-Normal",
                                                   UIFontDescriptorSizeAttribute: [NSNumber numberWithFloat:  self.centerLabel.frame.size.width/6.2]
                                                   }];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineSpacing:attributeFontDescriptor.pointSize *0.41];
    style.alignment = NSTextAlignmentCenter;
    
    if (isShowOutcome == 0) {
        attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"总支出\n%@",money]];
    }else
    {
        attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"总收入\n%@",money]];
    }
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.78];
    shadow.shadowBlurRadius = 0.0;
    shadow.shadowOffset = CGSizeMake(0.0, 1.0);
    
    [attrString addAttribute:NSParagraphStyleAttributeName
                       value:style
                       range:NSMakeRange(0, attrString.length)];
    [attrString addAttribute:NSForegroundColorAttributeName
                       value:TextColor
                       range:NSMakeRange(0, attrString.length)];
    [attrString addAttribute:NSShadowAttributeName
                       value:shadow
                       range:NSMakeRange(0, attrString.length)];
    
    self.centerLabel.font = [UIFont fontWithDescriptor:attributeFontDescriptor size:0.0];
    [self.centerLabel setAttributedText:attrString];
}
-(void)updatePieWith:(NSArray *)array
{
    [self.pieChart setItems:array];
    [self.pieChart recompute];
    [self.pieChart strokeChart];
}


-(void)configDetailTable
{
    self.detailTable = [[UITableView alloc] initWithFrame:CGRectMake(0, self.myPieView.frame.origin.y + self.myPieView.frame.size.height, SCREEN_WIDTH, SCREEN_HEIGHT- (self.myPieView.frame.origin.y + self.myPieView.frame.size.height)) style:UITableViewStylePlain];
    self.detailTable.showsVerticalScrollIndicator = YES;
    self.detailTable.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    self.detailTable.backgroundColor = [UIColor clearColor];
    self.detailTable.delegate = self;
    self.detailTable.dataSource = self;
    self.detailTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.detailTable];
    
}
-(void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
-(void)segmentAction:(UISegmentedControl *)Seg{
    NSInteger Index = Seg.selectedSegmentIndex;
    NSLog(@"Index %ld", (long)Index);
    
    self.timeWindowCategories = [self makePieData:Index];
    [self updatePieWith:self.timeWindowCategories];
    if (Index == 0) {
        [self makeMidText:Index ByMoney: [NSString stringWithFormat:@"%.0f",self.sumExpense]];
    }else
    {
        [self makeMidText:Index ByMoney: [NSString stringWithFormat:@"%.0f",self.sumIncome]];
    }
    
}



#pragma mark -
#pragma mark Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SCREEN_WIDTH/8;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelectRowAtIndexPath");
    
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didDeselectRowAtIndexPath");
}



#pragma mark -
#pragma mark Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.timeWindowCategories.count;
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"row:%ld",(long)indexPath.row);
    NSString *CellItemIdentifier = @"Cell1";
    
    PieExplainTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellItemIdentifier];
    if (cell == nil) {
        cell = [[PieExplainTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellItemIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        
    }
    NSString *category = @"";
    UIColor *categoryColor;
    NSString *money = @"";
    NSString *moneyRatio = @"";

    PNPieChartDataItem *oneItemOfPie = (PNPieChartDataItem *)self.timeWindowCategories[indexPath.row];
    category = oneItemOfPie.textDescription;
    categoryColor = oneItemOfPie.color;
    money = [NSString stringWithFormat:@"%.2f    |",oneItemOfPie.value];
    moneyRatio = [NSString stringWithFormat:@"%.2f%%",[self.pieChart ratioForItemAtIndex:indexPath.row] * 100];

    [cell.categoryName setText:category];
    [cell.money setText:money];
    [cell.MoneyRatio setText:moneyRatio];
    [cell.seperator setBackgroundColor:categoryColor];
    
    return cell;
    
}


@end
