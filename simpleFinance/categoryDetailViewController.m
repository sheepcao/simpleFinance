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


@interface categoryDetailViewController ()<UITableViewDataSource,UITableViewDelegate,FlatDatePickerDelegate>
{
    CGFloat fontSize;
}
@property (nonatomic,strong) topBarView *myTopBar;
@property (nonatomic ,strong) UITableView *itemsTable;
@property (nonatomic,strong) dateSelectView *dateView;
@property (nonatomic,strong) UILabel *startLabel;
@property (nonatomic,strong) UILabel *endLabel;
@property (nonatomic,strong) NSString *startTime;
@property (nonatomic,strong) NSString *endTime;
@end

@implementation categoryDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configTopbar];
    [self configItemsTable];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) prepareData
{
    
}


-(void)configTopbar
{
    topBarView *topBar = [[topBarView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 200)];
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
    [moneyRatio setText:@"137.86%"];
    moneyRatio.font = [UIFont fontWithName:@"HelveticaNeue" size:13.5f];
    moneyRatio.textAlignment = NSTextAlignmentCenter;
    [moneyRatio setTextColor:TextColor];
    [topBar addSubview:moneyRatio];
    
    UIView *seperatorLine1 = [[UILabel alloc] initWithFrame:CGRectMake(moneyRatio.frame.origin.x - 1,moneyRatio.frame.origin.y , 1, moneyRatio.frame.size.height)];
    [seperatorLine1 setBackgroundColor:[UIColor whiteColor]];
    [topBar addSubview:seperatorLine1];
    
    UIView *seperatorLine2 = [[UILabel alloc] initWithFrame:CGRectMake(moneyRatio.frame.origin.x +moneyRatio.frame.size.width + 1,moneyRatio.frame.origin.y , 1, moneyRatio.frame.size.height)];
    [seperatorLine2 setBackgroundColor:[UIColor whiteColor]];
    [topBar addSubview:seperatorLine2];
    
    UILabel *totalAmount = [[UILabel alloc] initWithFrame:CGRectMake(seperatorLine1.frame.origin.x - summaryLabelWidth - 40, moneyRatio.frame.origin.y, summaryLabelWidth+32, summaryLabelHeight)];
    [totalAmount setText:@"22483.00"];
    totalAmount.adjustsFontSizeToFitWidth = YES;
    totalAmount.font = [UIFont fontWithName:@"HelveticaNeue" size:13.5f];
    totalAmount.textAlignment = NSTextAlignmentRight;
    [totalAmount setTextColor:TextColor];
    [topBar addSubview:totalAmount];
    
    UILabel *totalCount = [[UILabel alloc] initWithFrame:CGRectMake(seperatorLine2.frame.origin.x +1 + 8, moneyRatio.frame.origin.y, summaryLabelWidth, summaryLabelHeight)];
    [totalCount setText:@"120 笔"];
    totalCount.adjustsFontSizeToFitWidth = YES;
    totalCount.font = [UIFont fontWithName:@"HelveticaNeue" size:13.5f];
    totalCount.textAlignment = NSTextAlignmentLeft;
    [totalCount setTextColor:TextColor];
    [topBar addSubview:totalCount];

}

-(void)configDateSelection
{
    self.dateView = [[dateSelectView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    dateShowView *showDateView = [[dateShowView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/5, 55, SCREEN_WIDTH*3/5, 45)];
    [self.myTopBar addSubview:showDateView];
    [showDateView.selectionButton addTarget:self action:@selector(dateSelect) forControlEvents:UIControlEventTouchUpInside];
    
  }

-(void)configItemsTable
{
    self.itemsTable = [[UITableView alloc] initWithFrame:CGRectMake(0, SCREEN_WIDTH*3/7 + 10, SCREEN_WIDTH, (SCREEN_HEIGHT- SCREEN_WIDTH/2)*3/4)];
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
    NSDate *startDate = [dateFormatter dateFromString:self.startLabel.text];
    [self.dateView.flatDatePicker setDate:startDate animated:NO];
    [self.dateView.flatDatePicker.labelTitle setText:[NSString stringWithFormat:@"开始时间: %@",self.startLabel.text]];
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
    NSDate *endDate = [dateFormatter dateFromString:self.endLabel.text];
    if (!datePicker.isSelectingEndTime) {
        self.startTime = value;
        [self.dateView.flatDatePicker setDate:endDate animated:NO];
        [datePicker.labelTitle setText:[NSString stringWithFormat:@"截止时间: %@",self.endLabel.text]];
        [datePicker makeTitle];
        
    }else
    {
        self.endTime = value;
//        [self prepareDataFrom:self.startTime toDate:self.endTime];
        
//        self.timeWindowCategories = [self makePieData:self.moneyTypeSeg.selectedSegmentIndex];
//        [self updatePieWith:self.timeWindowCategories];
//        [self.detailTable reloadData];
        
        [self.dateView removeFromSuperview];
        [self.startLabel setText:self.startTime];
        [self.endLabel setText:self.endTime];
        
    }
    
}


//to do: add table view's delegate and data source.



-(void)closeVC
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
