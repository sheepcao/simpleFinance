//
//  categoryManagementViewController.m
//  simpleFinance
//
//  Created by Eric Cao on 5/1/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "categoryManagementViewController.h"
#import "topBarView.h"
#import "global.h"
#import "BottomView.h"
#import "CommonUtility.h"
#import "categoryObject.h"
#import "categoryTableViewCell.h"

@interface categoryManagementViewController ()<UITableViewDataSource,UITableViewDelegate,categoryTapDelegate,UITextFieldDelegate>
{
    CGFloat bottomHeight;
    BOOL willShowDeleteBtn;
}
@property (nonatomic ,strong) UISegmentedControl *moneyTypeSeg;
@property (nonatomic ,strong) UITableView *categoryTableView;
@property (nonatomic,strong) FMDatabase *db;
@property (nonatomic,strong) NSMutableArray *incomeCategoryArray;
@property (nonatomic,strong) NSMutableArray *expenseCategoryArray;
@property (nonatomic,strong) UITextField *inputField;
@property (nonatomic,strong) UIView *inputView;


@end

@implementation categoryManagementViewController
@synthesize db;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    willShowDeleteBtn = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [self prepareCategoryData];
    
    [self configTopbar];
    [self configBottomView];
    [self configCategoryPad];
    [self configInputField];
}

-(void)prepareCategoryData
{
    self.expenseCategoryArray = [[NSMutableArray alloc] init];
    self.incomeCategoryArray = [[NSMutableArray alloc] init];
    
    db = [[CommonUtility sharedCommonUtility] db];
    if (![db open]) {
        NSLog(@"addNewItem/Could not open db.");
        return;
    }
    
    FMResultSet *rs = [db executeQuery:@"select * from CATEGORYINFO where is_deleted = 0"];
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
    [db close];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)configTopbar
{
    topBarView *topbar = [[topBarView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, topRowHeight)];
    topbar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:topbar];
    
    UIButton * closeViewButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 27, 60, 40)];
    closeViewButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    closeViewButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [closeViewButton setTitle:@"返回" forState:UIControlStateNormal];
    [closeViewButton setTitleColor:   [UIColor colorWithRed:76/255.0f green:101/255.0f blue:120/255.0f alpha:1.0f]forState:UIControlStateNormal];
    [closeViewButton addTarget:self action:@selector(closeVC) forControlEvents:UIControlEventTouchUpInside];
    closeViewButton.backgroundColor = [UIColor clearColor];
    [topbar addSubview:closeViewButton];
    
    UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-65, 27, 60, 40)];
    deleteButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    deleteButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [deleteButton setTitle:@"排序" forState:UIControlStateNormal];
    [deleteButton setTitleColor:   [UIColor colorWithRed:76/255.0f green:101/255.0f blue:120/255.0f alpha:1.0f]forState:UIControlStateNormal];
    [deleteButton addTarget:self action:@selector(deleteItem:) forControlEvents:UIControlEventTouchUpInside];
    deleteButton.backgroundColor = [UIColor clearColor];
    [topbar addSubview:deleteButton];
    
    NSArray *segmentedArray = [[NSArray alloc]initWithObjects:@"支出",@"收入",nil];
    self.moneyTypeSeg = [[UISegmentedControl alloc]initWithItems:segmentedArray];
    self.moneyTypeSeg.frame = CGRectMake(SCREEN_WIDTH*2/7, 30, SCREEN_WIDTH*3/7, 30);
    self.moneyTypeSeg.tintColor =  [UIColor colorWithRed:76/255.0f green:101/255.0f blue:120/255.0f alpha:1.0f];
    self.moneyTypeSeg.selectedSegmentIndex = 0;
    [self.moneyTypeSeg addTarget:self action:@selector(segmentAction:)forControlEvents:UIControlEventValueChanged];  //添加委托方法
    [topbar addSubview:self.moneyTypeSeg];
    
}

-(void)configBottomView
{
    if (IS_IPHONE_6P) {
        bottomHeight = 65;
    }else
    {
        bottomHeight = bottomBar;
    }
    
    
    BottomView *bottomView = [[BottomView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-bottomHeight, SCREEN_WIDTH, bottomHeight)];
    bottomView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:bottomView];
    
    UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH/2-1, bottomHeight)];
    UIButton *addNewButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2, 0, SCREEN_WIDTH/2, bottomHeight)];
    [deleteButton setTitle:@"删减" forState:UIControlStateNormal];
    [addNewButton setTitle:@"添加" forState:UIControlStateNormal];
    deleteButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    deleteButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    addNewButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    addNewButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [deleteButton addTarget:self action:@selector(deleteItem:) forControlEvents:UIControlEventTouchUpInside];
    [addNewButton addTarget:self action:@selector(addItem:) forControlEvents:UIControlEventTouchUpInside];
    
    [bottomView addSubview:deleteButton];
    [bottomView addSubview:addNewButton];
    
    UIView *midLine = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 1, 8, 1, bottomHeight-16)];
    midLine.backgroundColor = [UIColor whiteColor];
    [bottomView addSubview:midLine];
    
}


-(void) configCategoryPad
{
    
    
    UITableView *categoryTable = [[UITableView alloc] initWithFrame:CGRectMake(0, topRowHeight +10, SCREEN_WIDTH, SCREEN_HEIGHT - (topRowHeight) - bottomHeight)];
    
    categoryTable.showsVerticalScrollIndicator = YES;
    categoryTable.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    categoryTable.backgroundColor = [UIColor clearColor];
    categoryTable.delegate = self;
    categoryTable.dataSource = self;
    categoryTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    categoryTable.canCancelContentTouches = YES;
    categoryTable.delaysContentTouches = YES;
    self.categoryTableView = categoryTable;
    [self.view addSubview:categoryTable];
}

-(void)configInputField
{
    UIView *inputCategoryView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_WIDTH/6)];
    self.inputView = inputCategoryView;
    inputCategoryView.backgroundColor = [UIColor clearColor];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20,5, 50, inputCategoryView.frame.size.height-12)];
    [titleLabel setText:@"类 别 :"];
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.5f];
    titleLabel.textColor = [UIColor whiteColor];
    self.inputField = [[UITextField alloc] initWithFrame:CGRectMake(titleLabel.frame.origin.x + titleLabel.frame.size.width , 6, inputCategoryView.frame.size.width-(titleLabel.frame.origin.x + titleLabel.frame.size.width) - 60, inputCategoryView.frame.size.height-12)];
    //    self.inputField.placeholder = @"限4字以内";
    self.inputField.returnKeyType = UIReturnKeyDone;
    self.inputField.delegate = self;
    self.inputField.tintColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:0.9];
    self.inputField.font =  [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    self.inputField.textColor = TextColor;
    self.inputField.attributedPlaceholder =
    [[NSAttributedString alloc] initWithString:@"请输入(限4字以内)"
                                    attributes:@{
                                                 NSForegroundColorAttributeName: [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.9],
                                                 NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:13.5f]
                                                 }
     ];
    
    [self.view addSubview:inputCategoryView];
    [inputCategoryView addSubview:titleLabel];
    [inputCategoryView addSubview:self.inputField];
    
    UIButton *doneButton = [[UIButton alloc] initWithFrame:CGRectMake(self.inputView.frame.size.width-60, (self.inputView.frame.size.height -40)/2, 40, 40)];
    [doneButton setTitle:@"OK" forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(addNewCategory) forControlEvents:UIControlEventTouchUpInside];
    
    [inputCategoryView addSubview:doneButton];
    
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
    if (willShowDeleteBtn)
    {
        [cell showDeleteButton];
    }else
    {
        [cell removeDeleteButton];
    }
    
    return cell;
}

-(void)categoryDeleteTap:(UIButton *)sender
{
    NSLog(@"delete..........");
    UIButton *categoryButton;
    UIView *parentView = [sender.superview viewWithTag:(sender.tag - 10)]
    
    ;
    if ([parentView isKindOfClass:[UIButton class]]) {
        categoryButton = (UIButton *)parentView;
    }
    NSLog(@"categoryButton.text:%@",categoryButton.titleLabel.text);
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"" message:@"永久删除该类别?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* yesAction = [UIAlertAction actionWithTitle:@"是的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        db = [[CommonUtility sharedCommonUtility] db];
        if (![db open]) {
            NSLog(@"mainVC/Could not open db.");
            return;
        }
        
        BOOL sql = [db executeUpdate:@"update CATEGORYINFO set is_deleted = 1 where category_name=? and category_type = ?",categoryButton.titleLabel.text,[NSNumber numberWithInteger:self.moneyTypeSeg.selectedSegmentIndex]];
        if (!sql) {
            NSLog(@"ERROR: %d - %@", db.lastErrorCode, db.lastErrorMessage);
        }else
        {

            categoryObject *categoryDeleted;
            if (self.moneyTypeSeg.selectedSegmentIndex == 0) {
                for (categoryObject *oneCategory in self.expenseCategoryArray) {
                    if( [oneCategory.categoryName isEqualToString:categoryButton.currentTitle])
                    {
                        categoryDeleted = oneCategory;
                        break;
                    }
                }
                [self.expenseCategoryArray removeObject:categoryDeleted];
            }else
            {
                for (categoryObject *oneCategory in self.incomeCategoryArray) {
                    if( [categoryDeleted.categoryName isEqualToString:categoryButton.titleLabel.text])
                    {
                        categoryDeleted = oneCategory;
                        break;
                    }
                }
                [self.incomeCategoryArray addObject:categoryDeleted];
            }
            [self.categoryTableView reloadData];
        }
        [db close];
    }];
    
    UIAlertAction* noAction = [UIAlertAction actionWithTitle:@"不" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
    [alert addAction:yesAction];
    [alert addAction:noAction];
    [self presentViewController:alert animated:YES completion:nil];
    
    
}
-(void)categoryTap:(UIButton *)sender
{
    NSLog(@"do nothing");
}

-(void)closeVC
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)deleteItem:(UIButton *)sender
{
    NSLog(@"show delete button");
    if (willShowDeleteBtn) {
        [self hideDelete:sender];
    }else
    {
        
        [self showDelete:sender];
    }
    
}
-(void)showDelete:(UIButton *)sender
{
    [sender setTitle:@"取消" forState:UIControlStateNormal];
    willShowDeleteBtn = YES;
    [self.categoryTableView reloadData];
    
}
-(void)hideDelete:(UIButton *)sender
{
    [sender setTitle:@"删减" forState:UIControlStateNormal];
    willShowDeleteBtn = NO;
    [self.categoryTableView reloadData];
    
}

-(void)addItem:(UIButton *)sender
{
    NSLog(@"add Item....");
    
    
    [self.inputField becomeFirstResponder];
    
}
-(void)addNewCategory
{
    // to fix.....category OBJ
    NSString *newCategory = self.inputField.text;
//    NSInteger randomColor = arc4random()%255;
    
    categoryObject *oneCategory = [[categoryObject alloc] init];
    
    oneCategory.categoryName = newCategory;
    oneCategory.color_R  = arc4random()%255;
    oneCategory.color_G = arc4random()%255;
    oneCategory.color_B = arc4random()%255;
    
    if (![db open]) {
        NSLog(@"Could not open db.");
        return;
    }
    
    FMResultSet *rs = [db executeQuery:@"select * from CATEGORYINFO where is_deleted = 0 AND category_name = ? AND category_type = ?",[newCategory stringByReplacingOccurrencesOfString:@" " withString:@""],[NSNumber numberWithInteger: self.moneyTypeSeg.selectedSegmentIndex]];
    if ([rs next]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"" message:@"您输入的类别已经存在" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
        [db close];
        return;
    }

    
    BOOL sql = [db executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values (?,?,?,?,?)" ,[newCategory stringByReplacingOccurrencesOfString:@" " withString:@""],[NSNumber numberWithInteger: self.moneyTypeSeg.selectedSegmentIndex],[NSNumber numberWithDouble:oneCategory.color_R],[NSNumber numberWithDouble:oneCategory.color_G],[NSNumber numberWithDouble:oneCategory.color_B]];
    
    if (!sql) {
        NSLog(@"ERROR: %d - %@", db.lastErrorCode, db.lastErrorMessage);
    }else
    {
        if (self.moneyTypeSeg.selectedSegmentIndex == 0) {
            [self.expenseCategoryArray addObject:oneCategory];
        }else
        {
            [self.incomeCategoryArray addObject:oneCategory];
        }
        self.inputField.text = @"";
        [UIView animateWithDuration:0.25f animations:^{
            [self.inputView setFrame:CGRectMake(0, SCREEN_HEIGHT, self.inputView.frame.size.width, self.inputView.frame.size.height)];
        }];
        [self.view layoutIfNeeded];
        [self.inputField resignFirstResponder];
        
        [self.categoryTableView reloadData];
    }
    
    [db close];
}

-(void)keyboardWasShown:(NSNotification*)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.25f animations:^{
        [self.inputView setFrame:CGRectMake(0,SCREEN_HEIGHT - keyboardSize.height - self.inputView.frame.size.height, self.inputView.frame.size.width, self.inputView.frame.size.height)];
    }];
    
    [self.view layoutIfNeeded];
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


-(void)segmentAction:(UISegmentedControl *)Seg{
    NSInteger Index = Seg.selectedSegmentIndex;
    NSLog(@"Index %ld", (long)Index);
    
    
}
@end
