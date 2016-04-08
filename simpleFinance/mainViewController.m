//
//  ViewController.m
//  simpleFinance
//
//  Created by Eric Cao on 4/7/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "mainViewController.h"
#import "summeryTableViewCell.h"
#import "global.h"
#import "summeryViewController.h"


#define summaryViewHeight 136
#define bottomBar 50


@interface mainViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    CGFloat moneyLuckSpace;
}

@property (nonatomic,strong)UITableView *moneyDetailTable;
@end

@implementation mainViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    self.mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 65, SCREEN_WIDTH, SCREEN_HEIGHT- bottomBar -65)];
    self.mainScrollView.showsVerticalScrollIndicator = NO;
//    self.mainScrollView.backgroundColor = [UIColor purpleColor];
    
    [self.gradientView addSubview:self.mainScrollView];
    
    
    moneyLuckSpace = self.moneyLuckView.frame.size.height - self.mainScrollView.frame.origin.y;
    NSLog(@"moneyLuckSpace---:%f",moneyLuckSpace);
    [self.mainScrollView setContentSize:CGSizeMake(self.mainScrollView.frame.size.width, moneyLuckSpace+self.mainScrollView.frame.size.height)];
    
    summeryViewController *sammaryVC = [[summeryViewController alloc] initWithNibName:@"summeryViewController" bundle:nil];
    [self addChildViewController:sammaryVC];
    [sammaryVC.view setFrame:CGRectMake(0, moneyLuckSpace, SCREEN_WIDTH, summaryViewHeight)];
    [self.mainScrollView addSubview:sammaryVC.view];
    
     self.moneyDetailTable= [[UITableView alloc] initWithFrame:CGRectMake(0, sammaryVC.view.frame.origin.y + sammaryVC.view.frame.size.height, SCREEN_WIDTH, self.mainScrollView.frame.size.height-summaryViewHeight)];
    self.moneyDetailTable.delegate = self;
    self.moneyDetailTable.dataSource = self;
    [self.mainScrollView addSubview:self.moneyDetailTable];
    
    [self.mainScrollView setScrollEnabled:YES];
    [self.moneyDetailTable setScrollEnabled:NO];
    
    [self.mainScrollView addObserver: self forKeyPath: @"contentOffset" options: NSKeyValueObservingOptionNew context: nil];
    [self.moneyDetailTable addObserver: self forKeyPath: @"contentOffset" options: NSKeyValueObservingOptionNew context: nil];

    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    
    if (object == self.mainScrollView) {
        if (self.mainScrollView.contentOffset.y > moneyLuckSpace && self.moneyDetailTable.contentOffset.y <= 0.001)
        {
            [self.mainScrollView setScrollEnabled:NO];
            [self.moneyDetailTable setScrollEnabled:YES];
     
        }
//        else
//        {
//            [self.mainScrollView setUserInteractionEnabled:YES];
//            [self.moneyDetailTable setUserInteractionEnabled:NO];
//        }
    }
    
    if (object == self.moneyDetailTable) {
        if (self.mainScrollView.contentOffset.y <= moneyLuckSpace && self.moneyDetailTable.contentOffset.y <= 0.001)
        {
            [self.mainScrollView setScrollEnabled:YES];
            [self.moneyDetailTable setScrollEnabled:NO];
        }
//        else
//        {
//
//            [self.mainScrollView setUserInteractionEnabled:NO];
//            [self.moneyDetailTable setUserInteractionEnabled:YES];
//        }
    }
    
    
//    if (self.mainTableView.contentOffset.y<SCREEN_WIDTH/2+categoryViewHeight-44-44) {
//        
//        
//        
//        self.topBar.alpha = self.mainTableView.contentOffset.y/(SCREEN_WIDTH/2+categoryViewHeight-44-44);
//        
//        [self.fakeScroll setHidden:YES];
//        [self.menuScroll setHidden:NO];
//        
//        
//    }else
//    {
//        [self.fakeScroll setHidden:NO];
//        [self.menuScroll setHidden:YES];
//        
//        self.topBar.alpha = 1.0f;
//    }
    
}


- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
 

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark -
#pragma mark Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    if (section == 0) {
//        return 0;
//    }else if (section == 1) {
//        return 50;
//    
//}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
}




#pragma mark -
#pragma mark Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView             // Default is 1 if not implemented
{
    return 1;
}
//- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    if(section == 0 )
//    {
//        return nil;
//    }else if (section == 1)
//    {
//        UIView *header = [[UIView alloc] initWithFrame:CGRectMake(10,1 , 200, 40)];
//        header.backgroundColor = [UIColor redColor];
//        return header;
//    }else
//        return nil;
//}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

        return 20;
    
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cellForRowAtIndexPath");
    if (indexPath.section == 0) {
        static NSString *CellIdentifier = @"Cell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
        }
        
        return cell;
        
    }else if (indexPath.section == 1) {
        summeryTableViewCell *topCell =(summeryTableViewCell *) [tableView dequeueReusableCellWithIdentifier:@"summeryTableViewCell"];
        if (nil == topCell)
        {
            topCell = [[[NSBundle mainBundle]loadNibNamed:@"summeryTableViewCell" owner:self options:nil] objectAtIndex:0];//加载nib文件
            topCell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            topCell.backgroundColor = [UIColor clearColor];
            
        }
    
        
        return topCell;
        
    }else
    {
        static NSString *CellIdentifier = @"Cell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor greenColor];
        }
        
        return cell;
        
    }
    
}


- (IBAction)skinChange:(id)sender {
    NSLog(@"skinChange");
    self.gradientView.inputColor0 = [UIColor darkGrayColor];
    self.gradientView.inputColor1 = [UIColor blackColor];
    [self.gradientView setNeedsDisplay];
}
@end
