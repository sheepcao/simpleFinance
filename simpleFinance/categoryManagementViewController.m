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
#import "MBProgressHUD.h"

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
@property (nonatomic,strong) UIView *mySortView;
@property (nonatomic,strong) UIButton *myDeleteButton;
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
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    NSString*sortType = [[NSUserDefaults standardUserDefaults] objectForKey:@"sortType"];
    if (sortType) {
        [self prepareCategoryDataBy:sortType];
    }else
    {
        [self prepareCategoryDataBy:@"category_id"];
    }
    
    [self configBottomView];
    [self configCategoryPad];
    [self configInputField];
    [self configSortView];
    [self configTopbar];
    
}
-(void)dismissKeyboard {
    [self hideSortView];
    [self textFieldShouldReturn:self.inputField];
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
    
    UIButton *sortButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-65, 27, 60, 40)];
    sortButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    sortButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [sortButton setTitle:@"排序" forState:UIControlStateNormal];
    [sortButton setTitleColor:   [UIColor colorWithRed:76/255.0f green:101/255.0f blue:120/255.0f alpha:1.0f]forState:UIControlStateNormal];
    [sortButton addTarget:self action:@selector(showSortView) forControlEvents:UIControlEventTouchUpInside];
    sortButton.backgroundColor = [UIColor clearColor];
    [topbar addSubview:sortButton];
    
    NSArray *segmentedArray = [[NSArray alloc]initWithObjects:@"支出",@"收入",nil];
    self.moneyTypeSeg = [[UISegmentedControl alloc]initWithItems:segmentedArray];
    self.moneyTypeSeg.frame = CGRectMake(SCREEN_WIDTH*2/7, 30, SCREEN_WIDTH*3/7, 30);
    self.moneyTypeSeg.tintColor =  [UIColor colorWithRed:76/255.0f green:101/255.0f blue:120/255.0f alpha:1.0f];
    self.moneyTypeSeg.selectedSegmentIndex = 0;
    [self.moneyTypeSeg addTarget:self action:@selector(segmentAction:)forControlEvents:UIControlEventValueChanged];  //添加委托方法
    [topbar addSubview:self.moneyTypeSeg];
    
}
-(void)configSortView
{
    UIView *sortView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH, topRowHeight, SCREEN_WIDTH/3+10, 180)];
    sortView.layer.cornerRadius = 8;
    sortView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.9 alpha:1.0];
    [self.view addSubview:sortView];
    self.mySortView = sortView;
    NSArray *buttonTitle = @[@"系统推荐",@"最新添加",@"使用最多"];
    
    
    for (int i = 0; i<3; i++) {
        UIButton *sortBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0 + i*sortView.frame.size.height/3, sortView.frame.size.width-10, sortView.frame.size.height/3)];
        sortBtn.backgroundColor = [UIColor clearColor];
        [sortBtn setTitle:buttonTitle[i] forState:UIControlStateNormal];
        sortBtn.titleLabel.font =[UIFont fontWithName:@"HelveticaNeue" size:13.0f];
        sortBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 40);
        [sortBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        sortBtn.tag = i+1;
        [sortBtn addTarget:self action:@selector(sortTypeChange:) forControlEvents:UIControlEventTouchUpInside];
        
        UIImageView *selectedImage = [[UIImageView alloc] initWithFrame:CGRectMake(sortBtn.frame.size.width-40, sortBtn.frame.size.height/2 - 20 + i*sortView.frame.size.height/3, 40, 40)];
        selectedImage.tag = i+1+10;
        NSArray *sortKeys = @[@"category_id",@"recently create",@"usage"];
        NSString*sortType = [[NSUserDefaults standardUserDefaults] objectForKey:@"sortType"];
        
        
        if  ([sortKeys[i] isEqualToString:sortType])
        {
            [selectedImage setImage:[UIImage imageNamed:@"plus1.png"]];
        }else
        {
            [selectedImage setImage:[UIImage imageNamed:@"delete1.png"]];
            
        }
        
        [sortView addSubview:sortBtn];
        [sortView addSubview:selectedImage];
    }
    
}
-(void)sortTypeChange:(UIButton *)sender
{
    NSArray *sortKeys = @[@"category_id",@"recently create",@"usage"];
    
    for (int i = 0; i<3; i++) {
        UIImageView *selected =(UIImageView *) [self.mySortView viewWithTag:(i+1+10)];
        [selected setImage:[UIImage imageNamed:@"delete1.png"]];
    }
    UIImageView *selected =(UIImageView *) [self.mySortView viewWithTag:(sender.tag + 10)];
    [selected setImage:[UIImage imageNamed:@"plus1.png"]];
    
    [[NSUserDefaults standardUserDefaults] setObject:sortKeys[sender.tag -1] forKey:@"sortType"];
    
    [self prepareCategoryDataBy:sortKeys[sender.tag -1]];
    [self.categoryTableView reloadData];
    [self hideSortView];
    
    
}
-(void)showSortView
{
    [self hideDelete:self.myDeleteButton];
    
    if (self.mySortView.frame.origin.x>SCREEN_WIDTH-1)
    {
        [UIView animateWithDuration:0.31f animations:^{
            [self.mySortView setFrame:CGRectMake(SCREEN_WIDTH - self.mySortView.frame.size.width + 10, topRowHeight, self.mySortView.frame.size.width, self.mySortView.frame.size.height)];
        }];
    }else
    {
        [self hideSortView];
    }
    
}
-(void)hideSortView
{
    [UIView animateWithDuration:0.31f animations:^{
        [self.mySortView setFrame:CGRectMake(SCREEN_WIDTH, topRowHeight, self.mySortView.frame.size.width, self.mySortView.frame.size.height)];
    }];
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
    self.myDeleteButton = deleteButton;
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
    [self hideSortView];
    
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
    [self clearScreen];
    
    
    [self.inputField becomeFirstResponder];
    
}
-(void)addNewCategory
{
    [self clearScreen];
    NSString *newCategory = self.inputField.text;

    CGFloat width =  [self.inputField.text sizeWithAttributes:@{NSFontAttributeName:self.inputField.font}].width;
    NSLog(@"%f",width);
    if (width>74)
    {
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.animationType = MBProgressHUDAnimationZoom;
        hud.labelFont = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"您输入的类名过长";
        [hud hide:YES afterDelay:1.5];
        
        return;
    }else if ([[newCategory stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@"+新分类"] || [[newCategory stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""])
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.animationType = MBProgressHUDAnimationZoom;
        hud.labelFont = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"非法输入";
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
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"" message:@"您输入的类别已经存在" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
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
    }
    [db close];
}

-(void)dismissAlertMessage:(UIAlertController *)alert
{
    [alert dismissViewControllerAnimated:YES completion:nil];
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
    [self clearScreen];
    [self.categoryTableView reloadData];
    
}

-(void)clearScreen
{
    [self hideDelete:self.myDeleteButton];
    [self hideSortView];
}
@end
