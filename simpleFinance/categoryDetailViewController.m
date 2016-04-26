//
//  categoryDetailViewController.m
//  simpleFinance
//
//  Created by Eric Cao on 4/25/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#define summaryLabelWidth 60
#define summaryLabelHeight 20

#import "categoryDetailViewController.h"
#import "global.h"
#import "topBarView.h"
#import "dateSelectView.h"
#import "dateShowView.h"
#import "CommonUtility.h"
#import "itemObj.h"
#import "categoryItemsTableViewCell.h"
#import "itemDetailViewController.h"


@interface categoryDetailViewController ()<UITableViewDataSource,UITableViewDelegate,FlatDatePickerDelegate>
{
    CGFloat fontSize;
}
@property (nonatomic,strong) topBarView *myTopBar;
@property (nonatomic ,strong) UITableView *itemsTable;
@property (nonatomic,strong) dateSelectView *dateView;
@property (nonatomic,strong)  dateShowView *showTimeView;
@property (nonatomic,strong) NSString *startTime;
@property (nonatomic,strong) NSString *endTime;
@property (nonatomic,strong) NSMutableArray *timeWindowItems;
@property (nonatomic,strong) FMDatabase *db;

@property (nonatomic,strong) UILabel *moneyRatioLabel;
@property (nonatomic,strong) UILabel *moneyCountLabel;
@property (nonatomic,strong) UILabel *moneyLabel;

@end

@implementation categoryDetailViewController
@synthesize db;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configTopbar];
    [self configItemsTable];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self prepareDataFrom:self.startDate toDate:self.endDate];
    [self.itemsTable reloadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)prepareDataFrom:(NSString *)startDate toDate:(NSString *)endDate
{
    NSMutableArray *allItems= [[NSMutableArray alloc] init];
    
    db = [[CommonUtility sharedCommonUtility] db];
    if (![db open]) {
        NSLog(@"mainVC/Could not open db.");
        return;
    }
    
    NSString *nextEndDay = [[CommonUtility sharedCommonUtility] dateByAddingDays:endDate andDaysToAdd:1];
    
    
    FMResultSet *rs = [db executeQuery:@"select * from ITEMINFO where item_category = ? AND item_type = ? AND strftime('%s', create_time) BETWEEN strftime('%s', ?) AND strftime('%s', ?)", self.categoryName,[NSNumber numberWithInteger:self.categoryType],startDate,nextEndDay];
    
    while ([rs next]) {
        itemObj *oneItem = [[itemObj alloc] init];
        oneItem.itemID = [NSNumber numberWithInt: [rs intForColumn:@"item_id"]];
        oneItem.itemCategory  = [rs stringForColumn:@"item_category"];
        oneItem.itemDescription = [rs stringForColumn:@"item_description"];
        oneItem.itemType = [rs intForColumn:@"item_type"];
        oneItem.createdTime = [rs stringForColumn:@"create_time"];
        oneItem.moneyAmount = [rs doubleForColumn:@"money"];
        [allItems addObject:oneItem];
    }
    
    NSMutableDictionary *itemsDic = [[NSMutableDictionary alloc] init];
    
    for (itemObj *item in allItems) {

        NSArray *timeParts = [item.createdTime componentsSeparatedByString:@" "];
        NSString *dateString = timeParts[0];
        
        NSArray *itemsOneDay = [itemsDic objectForKey:dateString];
        if (!itemsOneDay) {
            NSArray *itemsAday = [[NSArray alloc] initWithObjects:item, nil];
            [itemsDic setObject:itemsAday forKey:dateString];
        }else
        {
            NSMutableArray *tempItemsOneDay = [[NSMutableArray alloc] initWithArray:itemsOneDay];
            [tempItemsOneDay addObject:item];
            NSArray *newItemsOneDay = [[NSArray alloc] initWithArray:tempItemsOneDay];
            [itemsDic setObject:newItemsOneDay forKey:dateString];
        }
    }
    
    if (!self.timeWindowItems) {
        self.timeWindowItems = [[NSMutableArray alloc] init];
    }else
    {
        [self.timeWindowItems removeAllObjects];
    }
    for (NSString *key in [itemsDic allKeys]) {
        [self.timeWindowItems addObject:[itemsDic objectForKey:key]];
    }
    
    //
    double catgoryMoney = 0.0f;
    FMResultSet *resultMoney = [db executeQuery:@"select sum(money) from ITEMINFO where strftime('%s', create_time) BETWEEN strftime('%s', ?) AND strftime('%s', ?) AND item_category = ? AND item_type = ?", startDate,nextEndDay,self.categoryName,[NSNumber numberWithInteger:self.categoryType]];
    if ([resultMoney next]) {
        catgoryMoney =  [resultMoney doubleForColumnIndex:0];
        [self.moneyLabel setText:[NSString stringWithFormat:@"%.2f",catgoryMoney]];
    }
    
    FMResultSet *resultRatio = [db executeQuery:@"select sum(money) from ITEMINFO where strftime('%s', create_time) BETWEEN strftime('%s', ?) AND strftime('%s', ?) AND item_type = ?", startDate,nextEndDay,[NSNumber numberWithInteger:self.categoryType]];
    if ([resultRatio next]) {
        double sumMoney =  [resultRatio doubleForColumnIndex:0];
        if (sumMoney>0.0001) {
            [self.moneyRatioLabel setText:[NSString stringWithFormat:@"%.2f%%",catgoryMoney*100/sumMoney]];
        }else
        {
            [self.moneyRatioLabel setText:@""];
        }
    }
    
    FMResultSet *resultCount = [db executeQuery:@"select count(*) from ITEMINFO where strftime('%s', create_time) BETWEEN strftime('%s', ?) AND strftime('%s', ?) AND item_category = ? AND item_type = ?", startDate,nextEndDay,self.categoryName,[NSNumber numberWithInteger:self.categoryType]];
    
    if ([resultCount next]) {
        int moneyCount =  [resultCount intForColumnIndex:0];
        [self.moneyCountLabel setText:[NSString stringWithFormat:@"%d 笔",moneyCount]];
    }
    [db close];
    
}



-(void)configTopbar
{
    topBarView *topBar = [[topBarView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 200+20)];
    topBar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:topBar];
    self.myTopBar = topBar;
    
    [self configDateSelection];
    
    UIButton * closeViewButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 27, 60, 40)];
    closeViewButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    closeViewButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [closeViewButton setTitle:@"返回" forState:UIControlStateNormal];
    [closeViewButton setTitleColor:   [UIColor colorWithRed:76/255.0f green:101/255.0f blue:120/255.0f alpha:1.0f]forState:UIControlStateNormal];
    [closeViewButton addTarget:self action:@selector(closeVC) forControlEvents:UIControlEventTouchUpInside];
    closeViewButton.backgroundColor = [UIColor clearColor];
    [topBar addSubview:closeViewButton];
    
    UILabel *titileLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 50, 22, 100, 50)];
    [titileLabel setText:@"分类明细"];
    titileLabel.font = [UIFont fontWithName:@"SourceHanSansCN-Normal" size:17.0f];
    titileLabel.textAlignment = NSTextAlignmentCenter;
    [titileLabel setTextColor:[UIColor colorWithRed:76/255.0f green:101/255.0f blue:120/255.0f alpha:1.0f]];
    [topBar addSubview:titileLabel];
    
    UILabel *categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/4, topBar.frame.size.height - 100,SCREEN_WIDTH/2,65)];
    UIFontDescriptor *attributeFontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                                 @{UIFontDescriptorFamilyAttribute: @"Helvetica Neue",
                                                   UIFontDescriptorNameAttribute:@"HelveticaNeue-UltraLight",
                                                   UIFontDescriptorSizeAttribute: [NSNumber numberWithFloat: SCREEN_WIDTH/8.5]
                                                   }];
    
    [categoryLabel setFont:[UIFont fontWithDescriptor:attributeFontDescriptor size:0.0]];
    categoryLabel.textColor = TextColor;
    categoryLabel.textAlignment = NSTextAlignmentCenter;
    categoryLabel.adjustsFontSizeToFitWidth = YES;
    [categoryLabel setText:self.categoryName];
    [topBar addSubview:categoryLabel];
    
    
    
    UILabel *moneyRatio = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - summaryLabelWidth/2,categoryLabel.frame.origin.y +categoryLabel.frame.size.height +10, summaryLabelWidth, summaryLabelHeight)];
    [moneyRatio setText:@""];
    moneyRatio.font = [UIFont fontWithName:@"HelveticaNeue" size:13.5f];
    moneyRatio.textAlignment = NSTextAlignmentCenter;
    [moneyRatio setTextColor:TextColor];
    [topBar addSubview:moneyRatio];
    self.moneyRatioLabel = moneyRatio;
    
    UIView *seperatorLine1 = [[UILabel alloc] initWithFrame:CGRectMake(moneyRatio.frame.origin.x - 1,moneyRatio.frame.origin.y , 1, moneyRatio.frame.size.height)];
    [seperatorLine1 setBackgroundColor:[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.8]];
    [topBar addSubview:seperatorLine1];
    
    UIView *seperatorLine2 = [[UILabel alloc] initWithFrame:CGRectMake(moneyRatio.frame.origin.x +moneyRatio.frame.size.width ,moneyRatio.frame.origin.y , 1, moneyRatio.frame.size.height)];
    [seperatorLine2 setBackgroundColor:[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.8]];
    [topBar addSubview:seperatorLine2];
    
    UILabel *totalAmount = [[UILabel alloc] initWithFrame:CGRectMake(seperatorLine1.frame.origin.x - summaryLabelWidth - 40, moneyRatio.frame.origin.y, summaryLabelWidth+32, summaryLabelHeight)];
    [totalAmount setText:@""];
    totalAmount.adjustsFontSizeToFitWidth = YES;
    totalAmount.font = [UIFont fontWithName:@"HelveticaNeue" size:13.5f];
    totalAmount.textAlignment = NSTextAlignmentRight;
    [totalAmount setTextColor:TextColor];
    [topBar addSubview:totalAmount];
    self.moneyLabel = totalAmount;
    
    UILabel *totalCount = [[UILabel alloc] initWithFrame:CGRectMake(seperatorLine2.frame.origin.x +1 + 8, moneyRatio.frame.origin.y, summaryLabelWidth, summaryLabelHeight)];
    [totalCount setText:@""];
    totalCount.adjustsFontSizeToFitWidth = YES;
    totalCount.font = [UIFont fontWithName:@"HelveticaNeue" size:13.5f];
    totalCount.textAlignment = NSTextAlignmentLeft;
    [totalCount setTextColor:TextColor];
    [topBar addSubview:totalCount];
    self.moneyCountLabel = totalCount;
}

-(void)configDateSelection
{
    self.dateView = [[dateSelectView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    dateShowView *showDateView = [[dateShowView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/5, 65, SCREEN_WIDTH*3/5, 45)];
    [showDateView.startLabel setText:self.startDate];
    [showDateView.endLabel setText:self.endDate];
    [self.myTopBar addSubview:showDateView];
    [showDateView.selectionButton addTarget:self action:@selector(dateSelect) forControlEvents:UIControlEventTouchUpInside];
    self.showTimeView = showDateView;
    
}

-(void)configItemsTable
{
    self.itemsTable = [[UITableView alloc] initWithFrame:CGRectMake(0, self.myTopBar.frame.size.height + self.myTopBar.frame.origin.y + 5, SCREEN_WIDTH, (SCREEN_HEIGHT- SCREEN_WIDTH/2)*3/4)];
    self.itemsTable.showsVerticalScrollIndicator = YES;
    self.itemsTable.indicatorStyle = UIScrollViewIndicatorStyleDefault;
    self.itemsTable.backgroundColor = [UIColor clearColor];
    self.itemsTable.delegate = self;
    self.itemsTable.dataSource = self;
    self.itemsTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.itemsTable];
    
}
//
-(void)dateSelect
{
    [self.view addSubview:self.dateView];
    self.dateView.flatDatePicker.delegate =self;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *startDate = [dateFormatter dateFromString:self.showTimeView.startLabel.text];
    [self.dateView.flatDatePicker setDate:startDate animated:NO];
    [self.dateView.flatDatePicker.labelTitle setText:[NSString stringWithFormat:@"开始时间: %@",self.showTimeView.startLabel.text]];
    [self.dateView.flatDatePicker makeTitle];
    
    [self.dateView.flatDatePicker show];
}


#pragma mark - FlatDatePicker Delegate

- (void)flatDatePicker:(FlatDatePicker*)datePicker dateDidChange:(NSDate*)date {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    
    NSString *value = [dateFormatter stringFromDate:date];
    
    NSLog(@"date picker:%@",value);
    if (!datePicker.isSelectingEndTime) {
        [datePicker.labelTitle setText:[NSString stringWithFormat:@"开始时间: %@",value]];
        [datePicker makeTitle];
        
    }else
    {
        [datePicker.labelTitle setText:[NSString stringWithFormat:@"截止时间: %@",value]];
        [datePicker makeTitle];
        
    }
    
}

- (void)flatDatePicker:(FlatDatePicker*)datePicker didCancel:(UIButton*)sender {
    [self.dateView removeFromSuperview];
}

- (void)flatDatePicker:(FlatDatePicker*)datePicker didValid:(UIButton*)sender date:(NSDate*)date {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *value = [dateFormatter stringFromDate:date];
    NSDate *endDate = [dateFormatter dateFromString:self.showTimeView.endLabel.text];
    if (!datePicker.isSelectingEndTime) {
        self.startTime = value;
        [self.dateView.flatDatePicker setDate:endDate animated:NO];
        [datePicker.labelTitle setText:[NSString stringWithFormat:@"截止时间: %@",self.showTimeView.endLabel.text]];
        [datePicker makeTitle];
        
    }else
    {
        self.endTime = value;
        [self prepareDataFrom:self.startTime toDate:self.endTime];
        
        [self.itemsTable reloadData];
        
        [self.dateView removeFromSuperview];
        [self.showTimeView.startLabel setText:self.startTime];
        [self.showTimeView.endLabel setText:self.endTime];
        
    }
    
}


#pragma mark -
#pragma mark Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SCREEN_WIDTH/8.5;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return SCREEN_WIDTH/16;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelectRowAtIndexPath");
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[categoryItemsTableViewCell class]]) {
        categoryItemsTableViewCell *itemCell = (categoryItemsTableViewCell *)cell;
        [itemCell.category setTextColor:[UIColor colorWithRed:1.0f green:0.65f blue:0.0f alpha:1.0f]];
        
        itemDetailViewController *itemDetailVC = [[itemDetailViewController alloc] initWithNibName:@"itemDetailViewController" bundle:nil];
        NSString *category = @"";
        NSString *categoryOnly = @"";
        NSString *description = @"";
        NSString *money = @"";
        NSString *itemTime = @"";
        NSNumber *itemID = @(-1);
        int itemType = -1;
        
        if (indexPath.section >= self.timeWindowItems.count ) {
            return;
        }else
        {
            NSArray *itemsOfDay = (NSArray *)self.timeWindowItems[indexPath.section];
            if (indexPath.row >= itemsOfDay.count) {
                return;
            }
            
            itemObj *oneItem = itemsOfDay[indexPath.row];
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
    if ([cell isKindOfClass:[categoryItemsTableViewCell class]]) {
        categoryItemsTableViewCell *itemCell = (categoryItemsTableViewCell *)cell;
        [itemCell.category setTextColor:TextColor];
    }
    
}

#pragma mark -
#pragma mark Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.timeWindowItems.count;
}
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, SCREEN_WIDTH/16)];
    headerView.backgroundColor = [UIColor clearColor];
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-80, 0, 160, headerView.frame.size.height)];
    dateLabel.textAlignment = NSTextAlignmentCenter;
    dateLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:SCREEN_WIDTH/23];
    dateLabel.textColor = [UIColor whiteColor];
    
    NSArray *itemsOfDay = (NSArray *)self.timeWindowItems[section];
    if(itemsOfDay.count>0)
    {
        itemObj *oneItem = itemsOfDay[0];
        [dateLabel setText:oneItem.createdTime];
    }
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSArray *itemsOfDay = (NSArray *)self.timeWindowItems[section];
    
    return itemsOfDay.count;
}

- (categoryItemsTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = @"categoryItemsCell";
    
    categoryItemsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[categoryItemsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
    }
    
    NSArray *itemsOfDay = (NSArray *)self.timeWindowItems[indexPath.section];
    if(itemsOfDay.count>indexPath.row)
    {
        itemObj *oneItem = itemsOfDay[indexPath.row];
        NSString *category = oneItem.itemCategory;
        NSString *description = oneItem.itemDescription;
        NSString *money = [NSString stringWithFormat:@"%.2f",oneItem.moneyAmount] ;
        
        if (![description isEqualToString:@""]) {
            description = [@" - " stringByAppendingString:description];
        }
        
        NSString *contentString = [NSString stringWithFormat:@"%@%@",category,description];
        [cell.category setText:contentString];
        [cell.money setText:money];
    }
    
    return cell;
    
}


-(void)closeVC
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
