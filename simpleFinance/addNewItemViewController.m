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




@interface addNewItemViewController ()<UITableViewDataSource,UITableViewDelegate,categoryTapDelegate>
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

@property (nonatomic,strong) FMDatabase *db;

@property (nonatomic,strong) NSMutableArray *incomeCategoryArray;
@property (nonatomic,strong) NSMutableArray *expenseCategoryArray;
@property (nonatomic,strong) NSString*sortType;

@property BOOL doingPlus;
@property BOOL doingMinus;
@property BOOL initialState;



@end

@implementation addNewItemViewController
@synthesize db;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
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
    
    // for editing item.
    [self configEditingItem];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
    
    [db close];
}

-(void)configTopbar
{
    topBarView *topbar = [[topBarView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, topRowHeight)];
    topbar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:topbar];
    
    UIButton * closeViewButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 27, 60, 40)];
    closeViewButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    closeViewButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [closeViewButton setTitle:@"取消" forState:UIControlStateNormal];
    [closeViewButton setTitleColor:   [UIColor colorWithRed:76/255.0f green:101/255.0f blue:120/255.0f alpha:1.0f]forState:UIControlStateNormal];
    [closeViewButton addTarget:self action:@selector(closeVC) forControlEvents:UIControlEventTouchUpInside];
    closeViewButton.backgroundColor = [UIColor clearColor];
    [topbar addSubview:closeViewButton];
    
    UIButton *saveButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-65, 27, 60, 40)];
    saveButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    saveButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [saveButton setTitle:@"保存" forState:UIControlStateNormal];
    [saveButton setTitleColor:   [UIColor colorWithRed:76/255.0f green:101/255.0f blue:120/255.0f alpha:1.0f]forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(saveItem:) forControlEvents:UIControlEventTouchUpInside];
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
    self.InputLabel.textColor = TextColor;
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
    self.categoryLabel.textColor = TextColor;
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
    UILabel *noteTitle = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 25, 3, 50, 18)];
    noteTitle.backgroundColor = [UIColor clearColor];
    UIFontDescriptor *attributeFontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                                 @{UIFontDescriptorFamilyAttribute: @"Helvetica Neue",
                                                   UIFontDescriptorNameAttribute:@"HelveticaNeue-Light",
                                                   UIFontDescriptorSizeAttribute: [NSNumber numberWithFloat: 17.0f]
                                                   }];
    [noteTitle setFont:[UIFont fontWithDescriptor:attributeFontDescriptor size:0.0]];
    [noteTitle setText:@"备注"];
    [noteTitle setTextColor:[UIColor whiteColor]];
    noteTitle.textAlignment = NSTextAlignmentCenter;
    
    
    UIButton *finishNoteButton = [[UIButton alloc] initWithFrame:CGRectMake(noteView.frame.size.width - 70, noteView.frame.size.height - 40, 70, 44)];
    [finishNoteButton setTitle:@"完成" forState:UIControlStateNormal];
    finishNoteButton.layer.cornerRadius = 4.0f;
    [finishNoteButton setBackgroundColor:[UIColor colorWithRed:242/255.0f green:191/255.0f blue:109/255.0f alpha:1.0f]];
    [finishNoteButton addTarget:self action:@selector(finishNote) forControlEvents:UIControlEventTouchUpInside];
    self.noteDoneButton = finishNoteButton;
    [noteView addSubview:finishNoteButton];
    
    
    UITextView *noteText = [[UITextView alloc] initWithFrame:CGRectMake(20, noteTitle.frame.origin.y+noteTitle.frame.size.height + 5, SCREEN_WIDTH-40, noteView.frame.size.height - (noteTitle.frame.origin.y+noteTitle.frame.size.height + 5) - finishNoteButton.frame.size.height)];
    UIFontDescriptor *bodyFontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                            @{UIFontDescriptorFamilyAttribute: @"Helvetica Neue",
                                              UIFontDescriptorNameAttribute:@"HelveticaNeue-LightItalic",
                                              UIFontDescriptorSizeAttribute: [NSNumber numberWithFloat: 13.0f]
                                              }];
    [noteText setFont:[UIFont fontWithDescriptor:bodyFontDescriptor size:0.0]];
    noteText.backgroundColor = [UIColor clearColor];
    [noteText setTextColor:[UIColor whiteColor]];
    noteText.textAlignment = NSTextAlignmentLeft;
    noteText.tintColor = [UIColor whiteColor];
    
    
    self.noteBody = noteText;
    [noteView addSubview:noteTitle];
    [noteView addSubview:noteText];
    
    
}

-(void)updateNotePad
{
    [self.noteDoneButton setFrame:CGRectMake(self.noteView.frame.size.width - 70, self.noteView.frame.size.height - 40, 70, 44)];
    [self.noteBody setFrame:CGRectMake(20, 25, SCREEN_WIDTH-40, self.noteView.frame.size.height - 25 - self.noteDoneButton.frame.size.height)];
    
}

-(void) configCategoryPad
{
    UITableView *categoryTable = [[UITableView alloc] initWithFrame:CGRectMake(0, self.inputAreaView.frame.origin.y + self.inputAreaView.frame.size.height +10, SCREEN_WIDTH, SCREEN_HEIGHT - (self.inputAreaView.frame.origin.y + self.inputAreaView.frame.size.height) - self.keyPadView.frame.size.height-20)];
    
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
            [self.noteBody becomeFirstResponder];
            
        }
        
    }
    
}

-(void)keyboardWasShown:(NSNotification*)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.25f animations:^{
        [self.noteView setFrame:CGRectMake(0, self.inputAreaView.frame.origin.y + self.inputAreaView.frame.size.height, self.noteView.frame.size.width, SCREEN_HEIGHT-keyboardSize.height-(self.inputAreaView.frame.origin.y + self.inputAreaView.frame.size.height))];
        [self updateNotePad];
    }];
    
    [self.view layoutIfNeeded];
}

-(void)finishNote
{
    [UIView animateWithDuration:0.25f animations:^{
        [self.noteView setFrame:CGRectMake(0, SCREEN_HEIGHT, self.noteView.frame.size.width, self.noteView.frame.size.height)];
    }];
    [self.view layoutIfNeeded];
    
    
    [self.noteBody resignFirstResponder];
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
        }
    }else
    {
        BOOL sql = [db executeUpdate:@"insert into ITEMINFO (item_category,item_type,item_description,money,target_date,create_time) values (?,?,?,?,?,datetime('now', 'localtime'))" , self.categoryLabel.text, [NSNumber numberWithInteger:self.moneyTypeSeg.selectedSegmentIndex],self.noteBody.text,[NSNumber numberWithDouble:[self.InputLabel.text doubleValue]],self.targetDate];
        
        if (!sql) {
            NSLog(@"ERROR: %d - %@", db.lastErrorCode, db.lastErrorMessage);
        }else
        {
            [self dismissViewControllerAnimated:YES completion:nil];
        }

    }
    [db close];
    
}

-(BOOL)validateData
{
    if ([self.InputLabel.text doubleValue]<0.001) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"" message:@"忘记输入记账金额了吧,亲" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
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
    [self.categoryLabel setText:sender.titleLabel.text];
    self.categoryLabel.layer.borderColor = sender.categoryColor.CGColor;
    
    //    [sender keySelectedStyle];
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma baseVC overwrite
- (void)configUIAppearance{
    NSLog(@"main config ui ");
    UIImageView *backImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [backImage setImage:[UIImage imageNamed:@"午.jpg"]];
    [self.view addSubview:backImage];
    [self.view sendSubviewToBack:backImage];
}



@end
