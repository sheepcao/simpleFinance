//
//  monthListViewController.m
//  simpleFinance
//
//  Created by Eric Cao on 5/4/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "monthListViewController.h"
#import "topBarView.h"
#import "global.h"
#import "RATreeView.h"
#import "RADataObject.h"
#import "RATableViewCell.h"
#import "dayRATableViewCell.h"
#import "itemRATableViewCell.h"
#import "CommonUtility.h"
#import "itemObj.h"

@interface monthListViewController ()<RATreeViewDelegate, RATreeViewDataSource>

@property(nonatomic,strong)  RATreeView * treeView;
@property(nonatomic,strong) NSArray * data;
@property (nonatomic,strong) topBarView *topBar;
@property (nonatomic,strong) FMDatabase *db;
@property (nonatomic,strong) NSMutableDictionary *monthlyDataDict;

@end

@implementation monthListViewController
@synthesize db;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareDB];
    
    // Do any additional setup after loading the view from its nib.
    [self configTopbar];
    [self configTable];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"Flow"];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"Flow"];
}

-(void)configTopbar
{
    self.topBar = [[topBarView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, topRowHeight + 5)];
    self.topBar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.topBar];
    
    UIButton * closeViewButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 32, 40, 40)];
    closeViewButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    closeViewButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [closeViewButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    closeViewButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
//    [closeViewButton setTitle:@"返回" forState:UIControlStateNormal];
    [closeViewButton setTitleColor:   normalColor forState:UIControlStateNormal];
    [closeViewButton addTarget:self action:@selector(closeVC) forControlEvents:UIControlEventTouchUpInside];
    closeViewButton.backgroundColor = [UIColor clearColor];
    [self.topBar addSubview:closeViewButton];
    
    [self.topBar.titleLabel  setText:NSLocalizedString(@"帐目流水",nil)];

    
    
}
-(void)closeVC
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)configTable
{
    self.treeView = [[RATreeView alloc] initWithFrame:CGRectMake(0, self.topBar.frame.size.height+5, SCREEN_WIDTH, SCREEN_HEIGHT - (self.topBar.frame.size.height+5))];
    self.treeView.backgroundColor = [UIColor clearColor];
    self.treeView.delegate = self;
    self.treeView.dataSource = self;
    self.treeView.separatorStyle = RATreeViewCellSeparatorStyleNone;
    
    [self.treeView reloadData];
    [self.view addSubview:self.treeView];
    [self.treeView registerNib:[UINib nibWithNibName:NSStringFromClass([RATableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([RATableViewCell class])];
    [self.treeView registerNib:[UINib nibWithNibName:NSStringFromClass([dayRATableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([dayRATableViewCell class])];
    [self.treeView registerNib:[UINib nibWithNibName:NSStringFromClass([itemRATableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([itemRATableViewCell class])];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark TreeView Delegate methods

- (CGFloat)treeView:(RATreeView *)treeView heightForRowForItem:(id)item
{
    NSInteger level = [self.treeView levelForCellForItem:item];
    if (level  == 0) {
        return 70;
    }else if(level == 1)
    {
        return 50;
    }
    return 26;
}


- (void)treeView:(RATreeView *)treeView willExpandRowForItem:(id)item
{
    NSInteger level = [self.treeView levelForCellForItem:item];
    RADataObject *dataObject = item;
    NSInteger numberOfChildren = [dataObject.children count];
    
    if (level == 0) {
        RATableViewCell *cell = (RATableViewCell *)[treeView cellForItem:item];
        if (numberOfChildren > 0) {
            [cell goExpendAnimated:YES];
        }
    }else if(level == 1)
    {
        dayRATableViewCell *cell = (dayRATableViewCell *)[treeView cellForItem:item];
        if (numberOfChildren > 0) {
            [cell goExpendAnimated:YES];
        }
    }else
    {
        
    }


    NSLog(@"expand");
}

- (void)treeView:(RATreeView *)treeView willCollapseRowForItem:(id)item
{
    NSInteger level = [self.treeView levelForCellForItem:item];
    RADataObject *dataObject = item;
    NSInteger numberOfChildren = [dataObject.children count];
    
    if (level == 0) {
        RATableViewCell *cell = (RATableViewCell *)[treeView cellForItem:item];
        if (numberOfChildren > 0) {
            [cell goCollapseAnimated:YES];
        }
    }else if(level == 1)
    {
        dayRATableViewCell *cell = (dayRATableViewCell *)[treeView cellForItem:item];
        if (numberOfChildren > 0) {
            [cell goCollapseAnimated:YES];
        }
    }}


#pragma mark TreeView Data Source

- (UITableViewCell *)treeView:(RATreeView *)treeView cellForItem:(id)item
{
    RADataObject *dataObject = item;
    
    NSInteger level = [self.treeView levelForCellForItem:item];
    NSInteger numberOfChildren = [dataObject.children count];
    BOOL expanded = [self.treeView isCellForItemExpanded:item];
    UITableViewCell * cell1;
    if (level == 0) {
        RATableViewCell *cell = [self.treeView dequeueReusableCellWithIdentifier:NSStringFromClass([RATableViewCell class])];
        [cell setupWithTitle:dataObject.name childCount:numberOfChildren level:level isExpanded:expanded andIncome:dataObject.income andExpense:dataObject.expense andColor:self.myTextColor];
        cell1 = cell;
    }else if(level == 1)
    {
        dayRATableViewCell *cell = [self.treeView dequeueReusableCellWithIdentifier:NSStringFromClass([dayRATableViewCell class])];
        [cell setupWithTitle:dataObject.name childCount:numberOfChildren level:level isExpanded:expanded andIncome:dataObject.income andExpense:dataObject.expense andColor:self.myTextColor];
        cell1 = cell;
    }else if (level == 2)
    {
        itemRATableViewCell *cell = [self.treeView dequeueReusableCellWithIdentifier:NSStringFromClass([itemRATableViewCell class])];
        [cell setupWithCategory:dataObject.name andDescription:dataObject.dataDescription andIncome:dataObject.income andExpense:dataObject.expense andColor:self.myTextColor];
        cell1 = cell;
    }
    
    cell1.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    
    return cell1;
}

- (NSInteger)treeView:(RATreeView *)treeView numberOfChildrenOfItem:(id)item
{
    if (item == nil) {
        return [self.data count];
    }
    
    RADataObject *data = item;
    return [data.children count];
}

- (id)treeView:(RATreeView *)treeView child:(NSInteger)index ofItem:(id)item
{
    RADataObject *data = item;
    if (item == nil) {
        return [self.data objectAtIndex:index];
    }
    
    return data.children[index];
}


//
//- (void)loadData
//{
//    RADataObject *phone1 = [RADataObject dataObjectWithName:@"Phone 1" children:nil];
//    RADataObject *phone2 = [RADataObject dataObjectWithName:@"Phone 2" children:nil];
//    RADataObject *phone3 = [RADataObject dataObjectWithName:@"Phone 3" children:nil];
//    RADataObject *phone4 = [RADataObject dataObjectWithName:@"Phone 4" children:nil];
//    
//    RADataObject *phone = [RADataObject dataObjectWithName:@"Phones"
//                                                  children:[NSArray arrayWithObjects:phone1, phone2, phone3, phone4, nil]];
//    
//    RADataObject *notebook1 = [RADataObject dataObjectWithName:@"Notebook 1" children:nil];
//    RADataObject *notebook2 = [RADataObject dataObjectWithName:@"Notebook 2" children:nil];
//    
//    RADataObject *computer1 = [RADataObject dataObjectWithName:@"Computer 1"
//                                                      children:[NSArray arrayWithObjects:notebook1, notebook2, nil]];
//    RADataObject *computer2 = [RADataObject dataObjectWithName:@"Computer 2" children:nil];
//    RADataObject *computer3 = [RADataObject dataObjectWithName:@"Computer 3" children:nil];
//    
//    RADataObject *computer = [RADataObject dataObjectWithName:@"Computers"
//                                                     children:[NSArray arrayWithObjects:computer1, computer2, computer3, nil]];
//    RADataObject *car = [RADataObject dataObjectWithName:@"Cars" children:nil];
//    RADataObject *bike = [RADataObject dataObjectWithName:@"Bikes" children:nil];
//    RADataObject *house = [RADataObject dataObjectWithName:@"Houses" children:nil];
//    RADataObject *flats = [RADataObject dataObjectWithName:@"Flats" children:nil];
//    RADataObject *motorbike = [RADataObject dataObjectWithName:@"Motorbikes" children:nil];
//    RADataObject *drinks = [RADataObject dataObjectWithName:@"Drinks" children:nil];
//    RADataObject *food = [RADataObject dataObjectWithName:@"Food" children:nil];
//    RADataObject *sweets = [RADataObject dataObjectWithName:@"Sweets" children:nil];
//    RADataObject *watches = [RADataObject dataObjectWithName:@"Watches" children:nil];
//    RADataObject *walls = [RADataObject dataObjectWithName:@"Walls" children:nil];
//    
//    self.data = [NSArray arrayWithObjects:phone, computer, car, bike, house, flats, motorbike, drinks, food, sweets, watches, walls, nil];
//    
//}

-(void)prepareDB
{
    self.monthlyDataDict = [[NSMutableDictionary alloc] init];
    
    db = [[CommonUtility sharedCommonUtility] db];
    if (![db open]) {
        NSLog(@"mainVC/Could not open db.");
        return;
    }
    NSString *minDate = @"2016-05-01";
    NSString *maxDate = @"2016-08-01";
    
    FMResultSet *rs = [db executeQuery:@"select target_date from ITEMINFO order by target_date LIMIT 1"];
    while ([rs next]) {
        minDate = [rs stringForColumn:@"target_date"];
    }
    FMResultSet *rs2 = [db executeQuery:@"select target_date from ITEMINFO order by target_date desc LIMIT 1"];
    while ([rs2 next]) {
        maxDate = [rs2 stringForColumn:@"target_date"];
    }
    
    NSArray *minArray = [minDate componentsSeparatedByString:@"-"];
    NSString *minYear = minArray[0];
    NSString *minMonth = minArray[1];
    
    NSArray *maxArray = [maxDate componentsSeparatedByString:@"-"];
    NSString *maxYear = maxArray[0];
    NSString *maxMonth = maxArray[1];
    
    NSInteger totalMonth = ([maxYear integerValue] - [minYear integerValue]) *12 + ([maxMonth integerValue] - [minMonth integerValue]) + 1;
    
    NSMutableArray *allMonth = [[NSMutableArray alloc] init];

    for (int i = 0; i<totalMonth; i ++) {
        
        NSMutableArray *monthArray = [[NSMutableArray alloc] init];
        
        NSInteger startYear = ([minMonth integerValue] + i - 1) /12 +[minYear integerValue];
        NSInteger startMonth = ([minMonth integerValue] + i ) %12;
        if (startMonth == 0) {
            startMonth = 12;
        }
        
        NSInteger endYear = ([minMonth integerValue] +( i+1) - 1) /12 +[minYear integerValue];
        NSInteger endMonth = ([minMonth integerValue] + (i + 1) ) %12;
        if (endMonth == 0) {
            endMonth = 12;
        }
        
        
        NSString *start = [NSString stringWithFormat:@"%ld-%02ld-01",(long)startYear,(long)startMonth];
        NSString *end = [NSString stringWithFormat:@"%ld-%02ld-01",(long)endYear,(long)endMonth];
        
        FMResultSet *rs = [db executeQuery:@"select distinct target_date from ITEMINFO where strftime('%s', target_date) BETWEEN strftime('%s', ?) AND strftime('%s', ?) order by target_date desc", start,end];
        while ([rs next]) {
            NSString *dateString = [rs stringForColumn:@"target_date"];
            NSArray *timeParts = [dateString componentsSeparatedByString:@" "];
            NSString *dateOnly = timeParts[0];
            
            if(![monthArray containsObject:dateOnly])
            {
                [monthArray addObject:dateOnly];
            }
        }
        
        NSString *monthName = [NSString stringWithFormat:@"%ld-%02ld",(long)startYear,(long)startMonth];
        RADataObject *monthData = [self dailyDataFrom:monthName withArray:monthArray duringStart:start andEnd:end];
        [allMonth addObject:monthData];
    }
    [db close];
    NSMutableArray *tempMonthArray = [[NSMutableArray alloc] init];

    for (int i = (int)allMonth.count-1 ; i>=0 ;i--) {
        [tempMonthArray addObject:allMonth[i]];
    }
    self.data = [NSArray arrayWithArray:tempMonthArray];
}

-( RADataObject *)dailyDataFrom:(NSString *)monthName  withArray:(NSArray *)monthlyArray duringStart:(NSString *)startDate andEnd:(NSString *)endDate
{
    NSMutableArray *monthlyDataArray = [[NSMutableArray alloc] init];
    
    for (NSString *date in monthlyArray) {
        NSMutableArray *oneDayItems = [[NSMutableArray alloc] init];
        NSString *nextDay = [[CommonUtility sharedCommonUtility] dateByAddingDays: date andDaysToAdd:1];
        
        FMResultSet *rs = [db executeQuery:@"select * from ITEMINFO where strftime('%s', target_date) BETWEEN strftime('%s', ?) AND strftime('%s', ?) order by target_date desc", date,nextDay];
        while ([rs next]) {
            itemObj *oneItem = [[itemObj alloc] init];
            
            oneItem.itemID = [NSNumber numberWithInt: [rs intForColumn:@"item_id"]];
            
            oneItem.itemCategory  = [rs stringForColumn:@"item_category"];
            oneItem.itemDescription = [rs stringForColumn:@"item_description"];
            oneItem.itemType = [rs intForColumn:@"item_type"];
            oneItem.createdTime = [rs stringForColumn:@"create_time"];
            oneItem.targetTime = [rs stringForColumn:@"target_date"];
            oneItem.moneyAmount = [rs doubleForColumn:@"money"];
            double income = -0.1;
            double expense = -0.1;
            if (oneItem.itemType == 0) {
                expense = oneItem.moneyAmount;
            }else
            {
                income = oneItem.moneyAmount;
            }
            
            RADataObject *itemData = [RADataObject dataObjectWithName: oneItem.itemCategory andIncome:income  andExpense:expense andDescription:oneItem.itemDescription children:nil];
            
            [oneDayItems addObject:itemData];
        }
        NSString *dayOnly = @"01";
        NSArray *dayOnlyArray = [date componentsSeparatedByString:@"-"];
        if (dayOnlyArray.count>2) {
            dayOnly = dayOnlyArray[2];
        }
        
        double sumIncome = 0.00f;
        double sumExpense = 0.00f;
        
        FMResultSet *resultIncome = [db executeQuery:@"select sum(money) from ITEMINFO where strftime('%s', target_date) BETWEEN strftime('%s', ?) AND strftime('%s', ?) AND item_type = 1", date,nextDay];
        if ([resultIncome next]) {
            sumIncome =  [resultIncome doubleForColumnIndex:0];
        }
        
        FMResultSet *resultExpense = [db executeQuery:@"select sum(money) from ITEMINFO where strftime('%s', target_date) BETWEEN strftime('%s', ?) AND strftime('%s', ?) AND item_type = 0", date,nextDay];
        
        if ([resultExpense next]) {
            sumExpense =  [resultExpense doubleForColumnIndex:0];
        }
        
        RADataObject *dailyData = [RADataObject dataObjectWithName:dayOnly andIncome:sumIncome andExpense:sumExpense andDescription:@"" children:oneDayItems];
        
        [monthlyDataArray addObject:dailyData];
    }
    
    double monthIncome = 0.00f;
    double monthExpense = 0.00f;
    FMResultSet *resultIncomeMonth = [db executeQuery:@"select sum(money) from ITEMINFO where strftime('%s', target_date) BETWEEN strftime('%s', ?) AND strftime('%s', ?) AND item_type = 1", startDate,endDate];
    if ([resultIncomeMonth next]) {
        monthIncome =  [resultIncomeMonth doubleForColumnIndex:0];
    }
    FMResultSet *resultExpenseMonth = [db executeQuery:@"select sum(money) from ITEMINFO where strftime('%s', target_date) BETWEEN strftime('%s', ?) AND strftime('%s', ?) AND item_type = 0", startDate,endDate];
    if ([resultExpenseMonth next]) {
        monthExpense =  [resultExpenseMonth doubleForColumnIndex:0];
    }

    RADataObject *monthlyData = [RADataObject dataObjectWithName:monthName andIncome:monthIncome andExpense:monthExpense andDescription:@"" children:monthlyDataArray];
    
    return monthlyData;
}



@end
