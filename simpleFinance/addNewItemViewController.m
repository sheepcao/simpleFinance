//
//  addNewItemViewController.m
//  simpleFinance
//
//  Created by Eric Cao on 4/12/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "addNewItemViewController.h"
#import "global.h"
#import "topBarView.h"
#import "RZTransitions.h"
#import "numberPadButton.h"
#import "LGGradientBackgroundView/LGGradientBackgroundView.h"
#import "categoryTableViewCell.h"
#import "CommonUtility.h"
#import "categoryObject.h"
#import "MBProgressHUD.h"




@interface addNewItemViewController ()<UITableViewDataSource,UITableViewDelegate,categoryTapDelegate,UITextFieldDelegate>
{
    categoryButton *lastCateBtn;
    BOOL isInputingNote;
    BOOL isAddingCategory;
    CGFloat btnHeight;
    
    

}
@property (nonatomic ,strong) UILabel *InputLabel;
@property (nonatomic ,strong) UILabel *categoryLabel;
@property (nonatomic ,strong) UISegmentedControl *moneyTypeSeg;
@property (nonatomic ,strong) NSString *InputNumberString;
@property (nonatomic ,strong) NSString *NumberToOperate;
@property (nonatomic ,strong) numberPadButton *plusBtn;
@property (nonatomic ,strong) numberPadButton *minusBtn;
@property (nonatomic ,strong) UIView *noteView;
@property (nonatomic ,strong) UITextView *noteBody;
@property (nonatomic ,strong) UIButton *noteDoneButton;
@property (nonatomic ,strong) UIView *keyPadView;
@property (nonatomic ,strong) UIView *inputAreaView;
@property (nonatomic ,strong) UITableView *categoryTableView;
@property (nonatomic ,strong) UIAlertController* alert ;
@property (nonatomic,strong) FMDatabase *db;

@property (nonatomic,strong) NSMutableArray *incomeCategoryArray;
@property (nonatomic,strong) NSMutableArray *expenseCategoryArray;
@property (nonatomic,strong) NSString*sortType;
@property (nonatomic,strong) UITextField *inputField;
@property (nonatomic,strong) UIView *inputView;

@property BOOL doingPlus;
@property BOOL doingMinus;
@property BOOL initialState;



@end

@implementation addNewItemViewController
@synthesize db;
@synthesize alert;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    isInputingNote = NO;
    isAddingCategory = NO;

    if (IS_IPHONE_4_OR_LESS) {
        btnHeight = 34;
    }else
    {
        btnHeight = 44;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    self.sortType = [[NSUserDefaults standardUserDefaults] objectForKey:@"sortType"];
    if (self.sortType) {
        [self prepareCategoryDataBy:self.sortType];
    }else
    {
        [self prepareCategoryDataBy:@"category_id"];
    }
    
    self.initialState = YES;
    [self configTopbar];
    [self configInputArea];
    [self configNumberPad];
    [self configCategoryPad];
    [self configNoteView];
    [self configInputField];
    
    // for editing item.
    [self configEditingItem];
    

}
-(void)dismissKeyboard {

    [self textFieldShouldReturn:self.inputField];

    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"addNewItem"];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"addNewItem"];
}

-(void)prepareCategoryDataBy:(NSString *)key
{
    if(self.expenseCategoryArray)
    {
        [self.expenseCategoryArray removeAllObjects];
    }else
    {
        self.expenseCategoryArray = [[NSMutableArray alloc] init];
        
    }
    if(self.incomeCategoryArray)
    {
        [self.incomeCategoryArray removeAllObjects];
    }else
    {
        self.incomeCategoryArray = [[NSMutableArray alloc] init];
        
    }
    
    db = [[CommonUtility sharedCommonUtility] db];
    if (![db open]) {
        NSLog(@"addNewItem/Could not open db.");
        return;
    }
    
    NSString *sqlCommand;
    if ([key isEqualToString:@"category_id"]) {
        sqlCommand = [NSString stringWithFormat:@"select * from CATEGORYINFO where is_deleted = 0 order by category_id"];
        
    }else if([key isEqualToString:@"recently create"])
    {
        sqlCommand = [NSString stringWithFormat:@"select * from CATEGORYINFO where is_deleted = 0 order by category_id desc"];
    }else
    {
        sqlCommand = [NSString stringWithFormat:@"select * from CATEGORYINFO where is_deleted = 0 order by category_id"];
        
    }
    
    FMResultSet *rs = [db executeQuery:sqlCommand];
    while ([rs next]) {
        categoryObject *oneCategory = [[categoryObject alloc] init];
        
        oneCategory.categoryName = [rs stringForColumn:@"category_name"];
        oneCategory.color_R  = [rs doubleForColumn:@"color_R"];
        oneCategory.color_G = [rs doubleForColumn:@"color_G"];
        oneCategory.color_B = [rs doubleForColumn:@"color_B"];
        
        if ([rs intForColumn:@"category_type"] == 0) {
            [self.expenseCategoryArray addObject:oneCategory];
        }else
        {
            [self.incomeCategoryArray addObject:oneCategory];
        }
    }
    if ([key isEqualToString:@"usage"])
    {
        FMResultSet *rs = [db executeQuery:@"SELECT count(*),item_category FROM ITEMINFO where item_type = 0 GROUP BY item_category ORDER BY count(*) DESC"];
        int i = 0;
        while ([rs next]) {
            NSString *cateName = [rs stringForColumn:@"item_category"];
            for (categoryObject *oneCate in self.expenseCategoryArray) {
                if ([oneCate.categoryName isEqualToString:cateName]) {
                    categoryObject *oneCateTemp = oneCate;
                    [self.expenseCategoryArray removeObject:oneCate];
                    [self.expenseCategoryArray insertObject:oneCateTemp atIndex:i];
                    i++;
                    break;
                }
                
            }
        }
        
        FMResultSet *rs2 = [db executeQuery:@"SELECT count(*),item_category FROM ITEMINFO where item_type = 1 GROUP BY item_category ORDER BY count(*) DESC"];
        int j = 0;
        while ([rs2 next]) {
            NSString *cateName = [rs2 stringForColumn:@"item_category"];
            for (categoryObject *oneCate in self.incomeCategoryArray) {
                if ([oneCate.categoryName isEqualToString:cateName]) {
                    [self.incomeCategoryArray removeObject:oneCate];
                    [self.incomeCategoryArray insertObject:oneCate atIndex:j];
                    j++;
                    break;
                }
                
            }
        }
    }
    
    categoryObject *oneCategory = [[categoryObject alloc] init];
    
    oneCategory.categoryName = NSLocalizedString(@"+ 新分类",nil);
    oneCategory.color_R  =245;
    oneCategory.color_G =245;
    oneCategory.color_B = 245;
    
    [self.incomeCategoryArray addObject:oneCategory];
    [self.expenseCategoryArray addObject:oneCategory];

    
    
    [db close];
}

-(void)configTopbar
{
    topBarView *topbar = [[topBarView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, topRowHeight+6)];
    topbar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:topbar];
    
    UIButton * closeViewButton = [[UIButton alloc] initWithFrame:CGRectMake(8, 30, 40, 40)];
    closeViewButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    closeViewButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [closeViewButton setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    closeViewButton.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
//    [closeViewButton setTitle:@"取消" forState:UIControlStateNormal];
    [closeViewButton setTitleColor:   normalColor forState:UIControlStateNormal];
    [closeViewButton addTarget:self action:@selector(closeVC) forControlEvents:UIControlEventTouchUpInside];
    closeViewButton.backgroundColor = [UIColor clearColor];
    [topbar addSubview:closeViewButton];
    
    UIButton *saveButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-52, 30, 40, 40)];
    saveButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    saveButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [saveButton setImage:[UIImage imageNamed:@"done"] forState:UIControlStateNormal];
    saveButton.imageEdgeInsets = UIEdgeInsetsMake(3.9, 3.9,3.9, 3.9);
    [saveButton setTitleColor:   normalColor forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(saveItem:) forControlEvents:UIControlEventTouchUpInside];
    saveButton.backgroundColor = [UIColor clearColor];
    [topbar addSubview:saveButton];
    
    NSArray *segmentedArray = [[NSArray alloc]initWithObjects:NSLocalizedString(@"支出",nil),NSLocalizedString(@"收入",nil),nil];
    self.moneyTypeSeg = [[UISegmentedControl alloc]initWithItems:segmentedArray];
    self.moneyTypeSeg.frame = CGRectMake(SCREEN_WIDTH*2/7, 32, SCREEN_WIDTH*3/7, 30);
    self.moneyTypeSeg.tintColor =  TextColor2;
    self.moneyTypeSeg.selectedSegmentIndex = 0;
    [self.moneyTypeSeg addTarget:self action:@selector(segmentAction:)forControlEvents:UIControlEventValueChanged];  //添加委托方法
    [topbar addSubview:self.moneyTypeSeg];
    
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    [self segmentAction:self.moneyTypeSeg];
}

-(void)segmentAction:(UISegmentedControl *)Seg{
    NSInteger Index = Seg.selectedSegmentIndex;
    NSLog(@"Index %ld", (long)Index);
    self.initialState =YES;
//    [self prepareCategoryDataBy:self.sortType];
    [self.categoryTableView reloadData];
    
}

-(void)configInputArea
{
    topBarView *inputView = [[topBarView alloc] initWithFrame:CGRectMake(0, topRowHeight, SCREEN_WIDTH, SCREEN_WIDTH/4)];
    inputView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:inputView];
    self.inputAreaView = inputView;
    self.InputLabel = [[UILabel alloc] initWithFrame:CGRectMake(categoryLabelWith, 5, SCREEN_WIDTH-15 - categoryLabelWith, SCREEN_WIDTH/4-15)];
    
    UIFontDescriptor *attributeFontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                                 @{UIFontDescriptorFamilyAttribute: @"Helvetica Neue",
                                                   UIFontDescriptorNameAttribute:@"HelveticaNeue-Thin",
                                                   UIFontDescriptorSizeAttribute: [NSNumber numberWithFloat: 42.0f]
                                                   }];
    
    [self.InputLabel setFont:[UIFont fontWithDescriptor:attributeFontDescriptor size:0.0]];
    self.InputLabel.textColor = self.myTextColor;
    self.InputLabel.textAlignment = NSTextAlignmentRight;
    self.InputLabel.adjustsFontSizeToFitWidth = YES;
    [inputView addSubview:self.InputLabel];
    
    self.InputNumberString = @"";
    self.NumberToOperate = @"0.00";
    [self.InputLabel setText:@"0.00"];
    
    
    self.categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, inputView.frame.size.height/2-17, categoryLabelWith-10, 34)];
    
    UIFontDescriptor *categoryFontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                                @{UIFontDescriptorFamilyAttribute: @"Helvetica Neue",
                                                  UIFontDescriptorNameAttribute:@"HelveticaNeue",
                                                  UIFontDescriptorSizeAttribute: [NSNumber numberWithFloat: 16.0f]
                                                  }];
    
    [self.categoryLabel setFont:[UIFont fontWithDescriptor:categoryFontDescriptor size:0.0]];
    self.categoryLabel.textColor = normalColor;
    self.categoryLabel.textAlignment = NSTextAlignmentCenter;
    self.categoryLabel.adjustsFontSizeToFitWidth = YES;
    [self.categoryLabel setText:@""];
    self.categoryLabel.layer.borderWidth = 2.0f;
    self.categoryLabel.layer.borderColor = symbolColor.CGColor;
    self.categoryLabel.layer.cornerRadius = 7;
    [inputView addSubview:self.categoryLabel];
    
    
}

-(void)configNoteView
{
    UIView *noteView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 150)];
    noteView.backgroundColor = numberColor;
    self.noteView = noteView;
    [self.view addSubview:noteView];
    UILabel *noteTitle = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 25, 3, 50, 17)];
    noteTitle.backgroundColor = [UIColor clearColor];
    UIFontDescriptor *attributeFontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                                 @{UIFontDescriptorFamilyAttribute: @"Helvetica Neue",
                                                   UIFontDescriptorNameAttribute:@"HelveticaNeue",
                                                   UIFontDescriptorSizeAttribute: [NSNumber numberWithFloat: 16.0f]
                                                   }];
    [noteTitle setFont:[UIFont fontWithDescriptor:attributeFontDescriptor size:0.0]];
    [noteTitle setText:NSLocalizedString(@"备 注",nil)];
    [noteTitle setTextColor:[UIColor whiteColor]];
    noteTitle.textAlignment = NSTextAlignmentCenter;
    

    UIButton *finishNoteButton = [[UIButton alloc] initWithFrame:CGRectMake(noteView.frame.size.width - 70, noteView.frame.size.height - btnHeight +4, 70, btnHeight)];
    [finishNoteButton setImage:[UIImage imageNamed:@"doneBig"] forState:UIControlStateNormal];
    [finishNoteButton setImageEdgeInsets:UIEdgeInsetsMake(0, 15, 2, 15)];
//    [finishNoteButton setTitle:@"完成" forState:UIControlStateNormal];
    finishNoteButton.layer.cornerRadius = 4.0f;
    [finishNoteButton setBackgroundColor:[UIColor colorWithRed:242/255.0f green:191/255.0f blue:109/255.0f alpha:1.0f]];
    [finishNoteButton addTarget:self action:@selector(finishNote) forControlEvents:UIControlEventTouchUpInside];
    self.noteDoneButton = finishNoteButton;
    [noteView addSubview:finishNoteButton];
    
    
    UITextView *noteText = [[UITextView alloc] initWithFrame:CGRectMake(20, noteTitle.frame.origin.y+noteTitle.frame.size.height + 5, SCREEN_WIDTH-40, noteView.frame.size.height - (noteTitle.frame.origin.y+noteTitle.frame.size.height + 5) - finishNoteButton.frame.size.height)];
    UIFontDescriptor *bodyFontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                            @{UIFontDescriptorFamilyAttribute: @"Helvetica Neue",
                                              UIFontDescriptorNameAttribute:@"HelveticaNeue-LightItalic",
                                              UIFontDescriptorSizeAttribute: [NSNumber numberWithFloat: 14.0f]
                                              }];
    [noteText setFont:[UIFont fontWithDescriptor:bodyFontDescriptor size:0.0]];
    noteText.backgroundColor = [UIColor clearColor];
    [noteText setTextColor:self.myTextColor];
    noteText.textAlignment = NSTextAlignmentLeft;
    noteText.tintColor = [UIColor whiteColor];
    
    self.noteBody = noteText;
    [noteView addSubview:noteTitle];
    [noteView addSubview:noteText];
    
    
}

-(void)updateNotePad
{
    [self.noteDoneButton setFrame:CGRectMake(self.noteView.frame.size.width - 70, self.noteView.frame.size.height - btnHeight + 4, 70, btnHeight)];
    [self.noteBody setFrame:CGRectMake(20, 25, SCREEN_WIDTH-40, self.noteView.frame.size.height - 25 - self.noteDoneButton.frame.size.height)];
    
}

-(void) configCategoryPad
{
    UITableView *categoryTable = [[UITableView alloc] initWithFrame:CGRectMake(0, self.inputAreaView.frame.origin.y + self.inputAreaView.frame.size.height +10, SCREEN_WIDTH, SCREEN_HEIGHT - (self.inputAreaView.frame.origin.y + self.inputAreaView.frame.size.height) - self.keyPadView.frame.size.height-10)];
    
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

-(void)configNumberPad
{
    UIView *numberPadView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - SCREEN_WIDTH*7/10, SCREEN_WIDTH, SCREEN_WIDTH*7/10)];
    self.keyPadView = numberPadView;
    numberPadView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:numberPadView];
    
    CGFloat buttonWidth = (numberPadView.frame.size.width-2)/4 ;
    CGFloat buttonHeight = (numberPadView.frame.size.height-2)/4  ;
    
    for (int i = 0; i<4; i++) { // 4 coloum
        for (int j = 0; j<4; j++) {  // 4 row
            numberPadButton * btn = [[numberPadButton alloc] initWithFrame:CGRectMake(1+i * (buttonWidth), 1+j*(buttonHeight), buttonWidth, buttonHeight)];
            
            btn.tag = j*4+i+1;
            [btn setupSymbols];
            [numberPadView addSubview:btn];
            if (btn.tag == 8) {
                self.plusBtn = btn;
                self.doingPlus = NO;
            }else if(btn.tag ==12)
            {
                self.minusBtn =btn;
                self.doingMinus = NO;
            }
            [btn setTitle:[NSString stringWithFormat:@"%@",btn.symbolText] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(keyTapped:) forControlEvents:UIControlEventTouchUpInside];
            
            
        }
    }
}

-(void)configInputField
{
    UIView *inputCategoryView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_WIDTH/6.5)];
    self.inputView = inputCategoryView;
    inputCategoryView.backgroundColor = [UIColor colorWithRed:173/255.0f  green:181/255.0f blue:190/255.0f alpha:1.0f];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15,5, 80, inputCategoryView.frame.size.height-12)];
    [titleLabel setText:NSLocalizedString(@"类 别 :",nil)];
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    titleLabel.textColor = [UIColor colorWithRed:0.18 green:0.19 blue:0.18 alpha:0.95f];
    self.inputField = [[UITextField alloc] initWithFrame:CGRectMake(titleLabel.frame.origin.x + titleLabel.frame.size.width , 6, inputCategoryView.frame.size.width-(titleLabel.frame.origin.x + titleLabel.frame.size.width) - 60, inputCategoryView.frame.size.height-12)];
    self.inputField.returnKeyType = UIReturnKeyDefault;
    self.inputField.delegate = self;
    self.inputField.tintColor = [UIColor colorWithRed:0.43 green:0.43 blue:0.43 alpha:0.88];
    self.inputField.font =  [UIFont fontWithName:@"HelveticaNeue" size:14.0f];
    self.inputField.textColor = [UIColor colorWithRed:0.1 green:0.12 blue:0.1 alpha:0.98];
    self.inputField.attributedPlaceholder =
    [[NSAttributedString alloc] initWithString:NSLocalizedString(@"请输入(限5字以内)",nil)
                                    attributes:@{
                                                 NSForegroundColorAttributeName: [UIColor colorWithRed:0.43 green:0.43 blue:0.43 alpha:0.88],
                                                 NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:13.5f]
                                                 }
     ];
    
    [self.view addSubview:inputCategoryView];
    [inputCategoryView addSubview:titleLabel];
    [inputCategoryView addSubview:self.inputField];
    
    UIButton *doneButton = [[UIButton alloc] initWithFrame:CGRectMake(self.inputView.frame.size.width-60, (self.inputView.frame.size.height -40)/2, 40, 40)];
    [doneButton setImage:[UIImage imageNamed:@"doneBig"] forState:UIControlStateNormal];
    [doneButton setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
//    [doneButton setTitle:@"OK" forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(addNewCategory) forControlEvents:UIControlEventTouchUpInside];
    
    [inputCategoryView addSubview:doneButton];
    
}


-(void)keyTapped:(numberPadButton *)sender
{
    //    NSLog(@"%@",sender.symbolText);
    
    if (sender.isNumber ){
        
        if (!self.plusBtn.enabled || !self.minusBtn.enabled) {
            self.InputNumberString = @"";
            [self.InputLabel setText:@""];
            
            [self.plusBtn keyNotSelectedStyle];
            [self.minusBtn keyNotSelectedStyle];
        }
        
        
        NSString *intPart = [self.InputLabel .text componentsSeparatedByString:@"."][0];
        if (intPart.length>10) {
            return;
        }
        if (sender.tag == 15 && [self.InputNumberString rangeOfString:@"."].length != 0)  {
            /* represent " . " key*/
            return;
        }else
        {
            self.InputNumberString =  [self.InputNumberString stringByAppendingString:sender.symbolText];
            
            if ( [self.InputNumberString rangeOfString:@"."].length != 0)  {
                NSString *clean = [NSString stringWithFormat:@"%.2f", [self.InputNumberString doubleValue]];
                [self.InputLabel setText:clean];
            }else
            {
                NSString *clean = [NSString stringWithFormat:@"%lld", [self.InputNumberString longLongValue]];
                [self.InputLabel setText:clean];
                
            }
        }
    }else
    {
        if(sender.tag == 4) // delete button
        {
            if (!self.plusBtn.enabled || !self.minusBtn.enabled) {
                [self.plusBtn keyNotSelectedStyle];
                [self.minusBtn keyNotSelectedStyle];
                self.doingMinus = NO;
                self.doingPlus = NO;
                
            }
            
            self.InputNumberString = self.InputLabel.text;
            if (self.InputNumberString.length == 0) {
                return;
            }else if (self.InputNumberString.length == 1) {
                self.InputNumberString = @"0";
            }else
            {
                self.InputNumberString = [self.InputNumberString substringToIndex:self.InputNumberString.length-1];
            }
            [self.InputLabel setText:self.InputNumberString];
        }
        
        if(sender.tag == 8) // ' + ' button
        {
            if (!self.minusBtn.enabled) {
                [self.minusBtn keyNotSelectedStyle];
                [sender keySelectedStyle];
                self.doingPlus = YES;
                self.doingMinus= NO;
                return;
            }
            
            if ([self.NumberToOperate doubleValue] > 0.0001 || [self.NumberToOperate doubleValue] < -0.0001) {
                
                if (self.doingPlus) {
                    double result = self.InputLabel.text.doubleValue + self.NumberToOperate.doubleValue;
                    NSString *resultText = [NSString stringWithFormat:@"%.2f",result];
                    if ([resultText rangeOfString:@".00"].length != 0) {
                        resultText = [resultText componentsSeparatedByString:@"."][0];
                    }
                    [self.InputLabel setText:resultText];
                }else if (self.doingMinus) {
                    double result = self.NumberToOperate.doubleValue - self.InputLabel.text.doubleValue;
                    if (result<0.0001) {
                        [self.InputLabel setText:@"0.00"];
                    }else
                    {
                        NSString *resultText = [NSString stringWithFormat:@"%.2f",result];
                        if ([resultText rangeOfString:@".00"].length != 0) {
                            resultText = [resultText componentsSeparatedByString:@"."][0];
                        }
                        [self.InputLabel setText:resultText];
                    }
                }
            }
            [sender keySelectedStyle];
            self.doingPlus = YES;
            self.doingMinus= NO;
            self.NumberToOperate = self.InputLabel.text;
            
        }
        
        if(sender.tag == 12) // ' - ' button
        {
            if (!self.plusBtn.enabled) {
                [self.plusBtn keyNotSelectedStyle];
                [sender keySelectedStyle];
                self.doingMinus = YES;
                self.doingPlus = NO;
                return;
            }
            
            if ([self.NumberToOperate doubleValue] > 0.0001 || [self.NumberToOperate doubleValue] < -0.0001) {
                
                if (self.doingPlus) {
                    double result = self.InputLabel.text.doubleValue + self.NumberToOperate.doubleValue;
                    NSString *resultText = [NSString stringWithFormat:@"%.2f",result];
                    if ([resultText rangeOfString:@".00"].length != 0) {
                        resultText = [resultText componentsSeparatedByString:@"."][0];
                    }
                    [self.InputLabel setText:resultText];
                }else if (self.doingMinus) {
                    double result = self.NumberToOperate.doubleValue - self.InputLabel.text.doubleValue;
                    if (result<0.0001) {
                        [self.InputLabel setText:@"0.00"];
                    }else
                    {
                        NSString *resultText = [NSString stringWithFormat:@"%.2f",result];
                        if ([resultText rangeOfString:@".00"].length != 0) {
                            resultText = [resultText componentsSeparatedByString:@"."][0];
                        }
                        [self.InputLabel setText:resultText];
                    }
                }
            }
            [sender keySelectedStyle];
            self.doingMinus = YES;
            self.doingPlus = NO;
            self.NumberToOperate = self.InputLabel.text;
            
        }
        
        if(sender.tag == 16)
        {
            if (!self.plusBtn.enabled || !self.minusBtn.enabled) {
                [self.plusBtn keyNotSelectedStyle];
                [self.minusBtn keyNotSelectedStyle];
                self.doingMinus = NO;
                self.doingPlus = NO;
                
            }
            
            if ([self.NumberToOperate doubleValue] > 0.0001 || [self.NumberToOperate doubleValue] < -0.0001) {
                
                if (self.doingPlus) {
                    double result = self.InputLabel.text.doubleValue + self.NumberToOperate.doubleValue;
                    NSString *resultText = [NSString stringWithFormat:@"%.2f",result];
                    if ([resultText rangeOfString:@".00"].length != 0) {
                        resultText = [resultText componentsSeparatedByString:@"."][0];
                    }
                    [self.InputLabel setText:resultText];
                }else if (self.doingMinus) {
                    double result = self.NumberToOperate.doubleValue - self.InputLabel.text.doubleValue;
                    if (result<0.0001) {
                        [self.InputLabel setText:@"0.00"];
                    }else
                    {
                        NSString *resultText = [NSString stringWithFormat:@"%.2f",result];
                        if ([resultText rangeOfString:@".00"].length != 0) {
                            resultText = [resultText componentsSeparatedByString:@"."][0];
                        }
                        [self.InputLabel setText:resultText];
                    }
                }else
                {
                    [self.InputLabel setText:self.NumberToOperate];
                }
                
                self.NumberToOperate = @"0.00";
                
            }
            
            if ([self.InputLabel.text isEqualToString:@"0.00"])
            {
                self.InputNumberString = @"";
            }else
            {
                self.InputNumberString = self.InputLabel.text;
            }
            
        }
        
        if (sender.tag == 13) // note button
        {
            isInputingNote = YES;
            isAddingCategory = NO;
            [self.noteBody becomeFirstResponder];
            
        }
        
    }
    
}

-(void)keyboardWasShown:(NSNotification*)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    if (isInputingNote) {
        [UIView animateWithDuration:0.25f animations:^{
            [self.noteView setFrame:CGRectMake(0, self.inputAreaView.frame.origin.y + self.inputAreaView.frame.size.height, self.noteView.frame.size.width, SCREEN_HEIGHT-keyboardSize.height-(self.inputAreaView.frame.origin.y + self.inputAreaView.frame.size.height))];
            [self updateNotePad];
        }];
    }else if (isAddingCategory)
    {
        [UIView animateWithDuration:0.25f animations:^{
            [self.inputView setFrame:CGRectMake(0,SCREEN_HEIGHT - keyboardSize.height - self.inputView.frame.size.height, self.inputView.frame.size.width, self.inputView.frame.size.height)];
        }];
    }
 
    [self.view layoutIfNeeded];
}

-(void)finishNote
{
    [UIView animateWithDuration:0.25f animations:^{
        [self.noteView setFrame:CGRectMake(0, SCREEN_HEIGHT, self.noteView.frame.size.width, self.noteView.frame.size.height)];
    }];
    [self.view layoutIfNeeded];
    

    [self.noteBody resignFirstResponder];
    isInputingNote = NO;
    isAddingCategory = NO;
    
    [MobClick event:@"addNote"];

}

-(void)closeVC
{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)saveItem:(UIButton *)sender
{
    NSLog(@"saving item...");
    if (![self validateData]) {
        return;
    }
    
    if (![db open]) {
        NSLog(@"addNewItemVC/Could not open db.");
        return;
    }

    if (self.isEditing) {
        BOOL sql = [db executeUpdate:@"update ITEMINFO set item_category=? ,item_type = ? ,item_description = ? ,money = ? where item_id = ?" ,self.categoryLabel.text, [NSNumber numberWithInteger:self.moneyTypeSeg.selectedSegmentIndex],self.noteBody.text,[NSNumber numberWithDouble:[self.InputLabel.text doubleValue]],self.editingID];
        if (!sql) {
            NSLog(@"ERROR123: %d - %@", db.lastErrorCode, db.lastErrorMessage);
        }else
        {
            [self.refreshDelegate refreshData];
            [self dismissViewControllerAnimated:YES completion:nil];
            
            [MobClick event:@"editItem"];

        }
    }else
    {
        BOOL sql = [db executeUpdate:@"insert into ITEMINFO (item_category,item_type,item_description,money,target_date,create_time) values (?,?,?,?,?,datetime('now', 'localtime'))" , self.categoryLabel.text, [NSNumber numberWithInteger:self.moneyTypeSeg.selectedSegmentIndex],self.noteBody.text,[NSNumber numberWithDouble:[self.InputLabel.text doubleValue]],self.targetDate];
        
        if (!sql) {
            NSLog(@"ERROR: %d - %@", db.lastErrorCode, db.lastErrorMessage);
        }else
        {
            [self dismissViewControllerAnimated:YES completion:nil];
            if (self.moneyTypeSeg.selectedSegmentIndex == 0) {
                [MobClick event:@"addItem"];
            }else
            {
                [MobClick event:@"addItemIncome"];
            }

        }

    }
    [db close];
    
}

-(BOOL)validateData
{
    if ([self.InputLabel.text doubleValue]<0.001) {
        
        UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"忘记输入记账金额了吧,亲",nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertview show];

        return NO;
    }
    
    return YES;
}

#pragma mark table delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ((int)(SCREEN_WIDTH/8));
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.moneyTypeSeg.selectedSegmentIndex == 0) {
        return (self.expenseCategoryArray.count/4) + 1;
    }else
    {
        return (self.incomeCategoryArray.count/4) + 1;
    }
}
- (categoryTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"categoryCell";
    
    categoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[categoryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.categoryDelegate = self;
    }
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    if (self.moneyTypeSeg.selectedSegmentIndex == 0) {
        if (self.expenseCategoryArray.count/4 > indexPath.row)
        {
            for (NSInteger  i = 4* indexPath.row; i < 4* (indexPath.row + 1); i++) {
                [tempArray addObject:self.expenseCategoryArray[i]];
            }
        }else
        {
            for (NSInteger  i = 4* indexPath.row; i < self.expenseCategoryArray.count; i++) {
                [tempArray addObject:self.expenseCategoryArray[i]];
            }
        }
    }else
    {
        if (self.incomeCategoryArray.count/4 > indexPath.row)
        {
            for (NSInteger  i = 4* indexPath.row; i < 4* (indexPath.row + 1); i++) {
                [tempArray addObject:self.incomeCategoryArray[i]];
            }
        }else
        {
            for (NSInteger  i = 4* indexPath.row; i < self.incomeCategoryArray.count; i++) {
                [tempArray addObject:self.incomeCategoryArray[i]];
            }
        }
    }
    [cell contentWithCategories:tempArray];
    
    if (indexPath.row == 0 && self.initialState && !self.isEditing) {
        [self categoryTap:cell.firstButton];
        self.initialState =NO;
    }
    
    
    return cell;
}

-(void)categoryTap:(categoryButton *)sender
{
    if ([sender.titleLabel.text isEqualToString:NSLocalizedString(@"+ 新分类",nil)])
    {
        isInputingNote = NO;
        isAddingCategory = YES;
        [self.inputField becomeFirstResponder];
        return;
    }
    
    [self.categoryLabel setText:sender.titleLabel.text];
    self.categoryLabel.layer.borderColor = sender.categoryColor.CGColor;
    if (!lastCateBtn)
    {
        lastCateBtn = sender;
    }else
    {
        [lastCateBtn categoryNormalColor];
        lastCateBtn = sender;

    }

    [sender categorySelectedColor:sender.categoryColor];
}


-(void)addNewCategory
{
    NSString *newCategory = [self.inputField.text stringByReplacingOccurrencesOfString:@" " withString:@""] ;
    
    CGFloat width =  [self.inputField.text sizeWithAttributes:@{NSFontAttributeName:self.inputField.font}].width;
    NSLog(@"%f",width);
    if (width>74)
    {
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.animationType = MBProgressHUDAnimationZoom;
        hud.labelFont = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = NSLocalizedString(@"您输入的类名过长",nil);
        [hud hide:YES afterDelay:1.5];
        
        return;
    }else if ([[newCategory stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:NSLocalizedString(@"+ 新分类",nil)] || [[newCategory stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""])
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.animationType = MBProgressHUDAnimationZoom;
        hud.labelFont = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = NSLocalizedString(@"非法输入",nil);
        [hud hide:YES afterDelay:1.2];
        return;
    }
    
    // to fix.....category OBJ
    //    NSInteger randomColor = arc4random()%255;
    
    
    if (![db open]) {
        NSLog(@"Could not open db.");
        return;
    }
    
    FMResultSet *rs = [db executeQuery:@"select * from CATEGORYINFO where is_deleted = 0 AND category_name = ? AND category_type = ?",[newCategory stringByReplacingOccurrencesOfString:@" " withString:@""],[NSNumber numberWithInteger: self.moneyTypeSeg.selectedSegmentIndex]];
    if ([rs next]) {
        UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"您输入的类别已经存在" ,nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertview show];

        [db close];
        return;
    }
    
    
    
    
    FMResultSet *rsColor = [db executeQuery:@"select * from COLORINFO order by used_count LIMIT 1"];
    if ([rsColor next]) {
        int colorID = [rsColor intForColumn:@"color_id"];
        int usedCount = [rsColor doubleForColumn:@"used_count"];
        
        double colorR = [rsColor doubleForColumn:@"color_R"];
        double colorG = [rsColor doubleForColumn:@"color_G"];
        double colorB = [rsColor doubleForColumn:@"color_B"];
        
        NSNumber * colorRed = [NSNumber numberWithDouble:colorR];
        NSNumber *colorGreen = [NSNumber numberWithDouble:colorG];
        NSNumber *colorBlue = [NSNumber numberWithDouble:colorB];
        
        
        
        BOOL sql = [db executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values (?,?,?,?,?)" ,[newCategory stringByReplacingOccurrencesOfString:@" " withString:@""],[NSNumber numberWithInteger: self.moneyTypeSeg.selectedSegmentIndex],colorRed,colorGreen,colorBlue];
        
        categoryObject *oneCategory = [[categoryObject alloc] init];
        
        oneCategory.categoryName = newCategory;
        oneCategory.color_R  = colorR;
        oneCategory.color_G = colorG;
        oneCategory.color_B = colorB;
        if (!sql) {
            NSLog(@"ERROR: %d - %@", db.lastErrorCode, db.lastErrorMessage);
        }else
        {
            [db executeUpdate:@"update  COLORINFO set used_count = ? where color_id = ?" ,[NSNumber numberWithInt:usedCount+1],[NSNumber numberWithInt:colorID]];
            
            if (self.moneyTypeSeg.selectedSegmentIndex == 0) {
                [self.expenseCategoryArray insertObject:oneCategory atIndex:self.expenseCategoryArray.count-1];
            }else
            {
                [self.incomeCategoryArray insertObject:oneCategory atIndex:self.incomeCategoryArray.count-1];
            }
            self.inputField.text = @"";
            [UIView animateWithDuration:0.25f animations:^{
                [self.inputView setFrame:CGRectMake(0, SCREEN_HEIGHT, self.inputView.frame.size.width, self.inputView.frame.size.height)];
            }];
            [self.view layoutIfNeeded];
            [self.inputField resignFirstResponder];
            [self.categoryTableView reloadData];
            
            [MobClick event:@"addCategory"];

        }
    }
    [db close];
}



#pragma mark prepare for edit item
-(void)configEditingItem
{
    if(self.isEditing)
    {
        [self.categoryLabel setText:self.editingCategory];
        self.categoryLabel.layer.borderColor = [[CommonUtility sharedCommonUtility] categoryColor:self.editingCategory].CGColor;
        
        [self.InputLabel setText:self.editingMoney];
        [self.noteBody setText:self.editingNote];
        [self.moneyTypeSeg setSelectedSegmentIndex:self.isEditingIncome];
    }
}


#pragma mark UITextField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [UIView animateWithDuration:0.25f animations:^{
        [self.inputView setFrame:CGRectMake(0, SCREEN_HEIGHT, self.inputView.frame.size.width, self.inputView.frame.size.height)];
    }];
    [self.view layoutIfNeeded];
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





@end
