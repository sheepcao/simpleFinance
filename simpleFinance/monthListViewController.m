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

@interface monthListViewController ()

//@property(nonatomic,strong)  JKExpandTableView * expandTableView;
@property(nonatomic,strong) NSMutableArray * dataModelArray;
@property (nonatomic,strong) topBarView *topBar;

@end

@implementation monthListViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self initializeSampleDataModel];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
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
//
//    self.expandTableView = [[JKExpandTableView alloc] initWithFrame:CGRectMake(0, self.topBar.frame.size.height + 5,SCREEN_WIDTH, (SCREEN_HEIGHT- self.topBar.frame.size.height - 5))];
//    self.expandTableView.showsVerticalScrollIndicator = NO;
//    self.expandTableView.scrollEnabled = NO;
//    self.expandTableView.backgroundColor = [UIColor clearColor];
//    self.expandTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
//    [self.expandTableView setDataSourceDelegate:self];
//    [self.expandTableView setTableViewDelegate:self];
//    [self.view addSubview:self.expandTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - JKExpandTableViewDelegate
- (void) initializeSampleDataModel {
    self.dataModelArray = [[NSMutableArray alloc] initWithCapacity:3];
    
    NSMutableArray *parent0 = [NSMutableArray arrayWithObjects:
                               [NSNumber numberWithBool:YES],
                               [NSNumber numberWithBool:NO],
                               [NSNumber numberWithBool:NO],
                               nil];
    NSMutableArray *parent1 = [NSMutableArray arrayWithObjects:
                               [NSNumber numberWithBool:NO],
                               [NSNumber numberWithBool:NO],
                               [NSNumber numberWithBool:NO],
                               nil];
    NSMutableArray *parent2 = [NSMutableArray arrayWithObjects:
                               [NSNumber numberWithBool:NO],
                               [NSNumber numberWithBool:YES],
                               nil];
    NSMutableArray *parent3 = [NSMutableArray arrayWithObjects:
                               [NSNumber numberWithBool:NO],
                               [NSNumber numberWithBool:YES],
                               [NSNumber numberWithBool:NO],
                               nil];
    [self.dataModelArray addObject:parent0];
    [self.dataModelArray addObject:parent1];
    [self.dataModelArray addObject:parent2];
    [self.dataModelArray addObject:parent3];
}

#pragma mark - JKExpandTableViewDelegate

- (BOOL) shouldSupportMultipleSelectableChildrenAtParentIndex:(NSInteger) parentIndex {
    return NO;
}
- (void) tableView:(UITableView *)tableView didSelectCellAtChildIndex:(NSInteger) childIndex withInParentCellIndex:(NSInteger) parentIndex {
    [[self.dataModelArray objectAtIndex:parentIndex] setObject:[NSNumber numberWithBool:YES] atIndex:childIndex];
    NSLog(@"data array: %@", self.dataModelArray);
}

- (void) tableView:(UITableView *)tableView didDeselectCellAtChildIndex:(NSInteger) childIndex withInParentCellIndex:(NSInteger) parentIndex {
    [[self.dataModelArray objectAtIndex:parentIndex] setObject:[NSNumber numberWithBool:NO] atIndex:childIndex];
    NSLog(@"data array: %@", self.dataModelArray);
}

 - (UIColor *) foregroundColor {
 return [UIColor clearColor];
 }
 
 - (UIColor *) backgroundColor {
 return [UIColor clearColor];
 }

- (UIFont *) fontForParents {
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f];
}

- (UIFont *) fontForChildren {
    return [UIFont fontWithName:@"HelveticaNeue" size:14.5f];
}

#pragma mark - JKExpandTableViewDataSource
- (NSInteger) numberOfParentCells {
    NSLog(@"count-----------------:%d",[self.dataModelArray count]);
    return [self.dataModelArray count];
}

- (NSInteger) numberOfChildCellsUnderParentIndex:(NSInteger) parentIndex {
    NSMutableArray *childArray = [self.dataModelArray objectAtIndex:parentIndex];
    return [childArray count];
}

- (NSString *) labelForParentCellAtIndex:(NSInteger) parentIndex {
    return [NSString stringWithFormat:@"parent %ld", (long)parentIndex];
}

- (NSString *) labelForCellAtChildIndex:(NSInteger) childIndex withinParentCellIndex:(NSInteger) parentIndex {
    return [NSString stringWithFormat:@"child %ld of parent %ld", (long)childIndex, (long)parentIndex];
}

- (BOOL) shouldDisplaySelectedStateForCellAtChildIndex:(NSInteger) childIndex withinParentCellIndex:(NSInteger) parentIndex {
    NSMutableArray *childArray = [self.dataModelArray objectAtIndex:parentIndex];
    return [[childArray objectAtIndex:childIndex] boolValue];
}

- (UIImage *) iconForParentCellAtIndex:(NSInteger) parentIndex {
    return [UIImage imageNamed:@"arrow-icon"];
}


@end
