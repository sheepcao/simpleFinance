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

@interface monthListViewController ()<RATreeViewDelegate, RATreeViewDataSource>

@property(nonatomic,strong)  RATreeView * treeView;
@property(nonatomic,strong) NSArray * data;
@property (nonatomic,strong) topBarView *topBar;

@end

@implementation monthListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadData];

    // Do any additional setup after loading the view from its nib.
    [self configTopbar];
    [self configTable];

}

-(void)configTopbar
{
    self.topBar = [[topBarView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, topRowHeight + 5)];
    self.topBar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.topBar];
    
    UIButton * closeViewButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 27, 60, 40)];
    closeViewButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    closeViewButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [closeViewButton setTitle:@"返回" forState:UIControlStateNormal];
    [closeViewButton setTitleColor:   [UIColor colorWithRed:76/255.0f green:101/255.0f blue:120/255.0f alpha:1.0f]forState:UIControlStateNormal];
    [closeViewButton addTarget:self action:@selector(closeVC) forControlEvents:UIControlEventTouchUpInside];
    closeViewButton.backgroundColor = [UIColor clearColor];
    [self.topBar addSubview:closeViewButton];
    
    UILabel *titileLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 50, 22, 100, 50)];
    [titileLabel setText:@"帐目流水"];
    titileLabel.font = [UIFont fontWithName:@"SourceHanSansCN-Normal" size:titleSize];
    titileLabel.textAlignment = NSTextAlignmentCenter;
    [titileLabel setTextColor:[UIColor colorWithRed:76/255.0f green:101/255.0f blue:120/255.0f alpha:1.0f]];
    [self.topBar addSubview:titileLabel];
    
    
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
        return 48;
    }
    return 40;
}


- (void)treeView:(RATreeView *)treeView willExpandRowForItem:(id)item
{
    RATableViewCell *cell = (RATableViewCell *)[treeView cellForItem:item];
    RADataObject *dataObject = item;
    NSInteger numberOfChildren = [dataObject.children count];
    if (numberOfChildren > 0) {
        [cell goExpendAnimated:YES];
    }
    NSLog(@"expand");
}

- (void)treeView:(RATreeView *)treeView willCollapseRowForItem:(id)item
{
    RATableViewCell *cell = (RATableViewCell *)[treeView cellForItem:item];
    RADataObject *dataObject = item;
    NSInteger numberOfChildren = [dataObject.children count];
    if (numberOfChildren > 0) {
        [cell goCollapseAnimated:YES];
    }    NSLog(@"collapse");

}


#pragma mark TreeView Data Source

- (UITableViewCell *)treeView:(RATreeView *)treeView cellForItem:(id)item
{
    RADataObject *dataObject = item;
    
    NSInteger level = [self.treeView levelForCellForItem:item];
    NSInteger numberOfChildren = [dataObject.children count];
    NSString *detailText = [NSString localizedStringWithFormat:@"Number of children %@", [@(numberOfChildren) stringValue]];
    BOOL expanded = [self.treeView isCellForItemExpanded:item];
    UITableViewCell * cell1;
    if (level == 0) {
        RATableViewCell *cell = [self.treeView dequeueReusableCellWithIdentifier:NSStringFromClass([RATableViewCell class])];
        [cell setupWithTitle:dataObject.name childCount:numberOfChildren level:level isExpanded:expanded];
        cell1 = cell;
    }else if(level == 1)
    {
        dayRATableViewCell *cell = [self.treeView dequeueReusableCellWithIdentifier:NSStringFromClass([dayRATableViewCell class])];
        [cell setupWithTitle:dataObject.name childCount:numberOfChildren level:level isExpanded:expanded];
        cell1 = cell;
    }else if (level == 2)
    {
        itemRATableViewCell *cell = [self.treeView dequeueReusableCellWithIdentifier:NSStringFromClass([itemRATableViewCell class])];
        [cell setupWithCategory:@"吃喝" andDescription:@"老铺烤鸭" andMoney:233 andType:0];
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



- (void)loadData
{
    RADataObject *phone1 = [RADataObject dataObjectWithName:@"Phone 1" children:nil];
    RADataObject *phone2 = [RADataObject dataObjectWithName:@"Phone 2" children:nil];
    RADataObject *phone3 = [RADataObject dataObjectWithName:@"Phone 3" children:nil];
    RADataObject *phone4 = [RADataObject dataObjectWithName:@"Phone 4" children:nil];
    
    RADataObject *phone = [RADataObject dataObjectWithName:@"Phones"
                                                  children:[NSArray arrayWithObjects:phone1, phone2, phone3, phone4, nil]];
    
    RADataObject *notebook1 = [RADataObject dataObjectWithName:@"Notebook 1" children:nil];
    RADataObject *notebook2 = [RADataObject dataObjectWithName:@"Notebook 2" children:nil];
    
    RADataObject *computer1 = [RADataObject dataObjectWithName:@"Computer 1"
                                                      children:[NSArray arrayWithObjects:notebook1, notebook2, nil]];
    RADataObject *computer2 = [RADataObject dataObjectWithName:@"Computer 2" children:nil];
    RADataObject *computer3 = [RADataObject dataObjectWithName:@"Computer 3" children:nil];
    
    RADataObject *computer = [RADataObject dataObjectWithName:@"Computers"
                                                     children:[NSArray arrayWithObjects:computer1, computer2, computer3, nil]];
    RADataObject *car = [RADataObject dataObjectWithName:@"Cars" children:nil];
    RADataObject *bike = [RADataObject dataObjectWithName:@"Bikes" children:nil];
    RADataObject *house = [RADataObject dataObjectWithName:@"Houses" children:nil];
    RADataObject *flats = [RADataObject dataObjectWithName:@"Flats" children:nil];
    RADataObject *motorbike = [RADataObject dataObjectWithName:@"Motorbikes" children:nil];
    RADataObject *drinks = [RADataObject dataObjectWithName:@"Drinks" children:nil];
    RADataObject *food = [RADataObject dataObjectWithName:@"Food" children:nil];
    RADataObject *sweets = [RADataObject dataObjectWithName:@"Sweets" children:nil];
    RADataObject *watches = [RADataObject dataObjectWithName:@"Watches" children:nil];
    RADataObject *walls = [RADataObject dataObjectWithName:@"Walls" children:nil];
    
    self.data = [NSArray arrayWithObjects:phone, computer, car, bike, house, flats, motorbike, drinks, food, sweets, watches, walls, nil];
    
}




@end
