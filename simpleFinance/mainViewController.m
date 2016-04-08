//
//  ViewController.m
//  simpleFinance
//
//  Created by Eric Cao on 4/7/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "mainViewController.h"
#import "global.h"
#import "summeryViewController.h"
#import "myMaskTableViewCell.h"
#import "MFSideMenu.h"






@interface mainViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>
{
    CGFloat moneyLuckSpace;
    CGFloat bottomHeight;

}

@end

@implementation mainViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (IS_IPHONE_6P) {
        bottomHeight = 65;
    }else
    {
        bottomHeight = bottomBar;
    }
    
    self.navigationController.navigationBarHidden = YES;
    UIFontDescriptor *attributeFontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                                 @{UIFontDescriptorFamilyAttribute: @"Marion",
                                                   UIFontDescriptorNameAttribute:@"Marion-Thin",
                                                   UIFontDescriptorSizeAttribute: @15.2f
                                                   }];
    self.luckyText.font = [UIFont fontWithDescriptor:attributeFontDescriptor size:0.0];
    
    [self.luckyText setText:@"本周财运:\n\t理财敏感度高，适合做长远布局，尤其是不用辛苦上班就可以有收益这类的被动收入，如房租、股权分红等等值得挖掘。"];

    self.luckyText.alpha = 1.0f;
    
    self.maintableView = [[UITableView alloc] initWithFrame:CGRectMake(0, topBarHeight, SCREEN_WIDTH, SCREEN_HEIGHT- bottomHeight -topBarHeight) style:UITableViewStylePlain];
    self.maintableView.showsVerticalScrollIndicator = NO;
    self.maintableView.backgroundColor = [UIColor clearColor];
    self.maintableView.delegate = self;
    self.maintableView.dataSource = self;
    self.maintableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.maintableView.canCancelContentTouches = YES;
    self.maintableView.delaysContentTouches = YES;
    [self.gradientView addSubview:self.maintableView];
    [self.gradientView bringSubviewToFront:self.maintableView];
    
    
    moneyLuckSpace = self.moneyLuckView.frame.size.height + self.moneyLuckView.frame.origin.y - topBarHeight;
    NSLog(@"moneyLuckSpace---:%f",moneyLuckSpace);
    
    [self.maintableView addObserver: self forKeyPath: @"contentOffset" options: NSKeyValueObservingOptionNew context: nil];

    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (self.maintableView.contentOffset.y > -0.0001 && self.maintableView.contentOffset.y - moneyLuckSpace/2 < 0.000001) {
        
        self.luckyText.alpha = 1.0 - self.maintableView.contentOffset.y/(moneyLuckSpace/2);
        
        
    }else if (self.maintableView.contentOffset.y > -0.0001)
    {
        self.luckyText.alpha = 0.0f;
    }
    
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
    if (indexPath.section == 0) {
        if (IS_IPHONE_5_OR_LESS) {
            return moneyLuckSpace-40;
        }else
        {
            return moneyLuckSpace;
        }
    }else
        return rowHeight;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    }else if (section == 1) {
        return summaryViewHeight;
    }else
        return 0;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
}




#pragma mark -
#pragma mark Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView             // Default is 1 if not implemented
{
    return 2;
}
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 0 )
    {
        return nil;
    }else if (section == 1)
    {
        summeryViewController *summaryVC = [[summeryViewController alloc] initWithNibName:@"summeryViewController" bundle:nil];
        [summaryVC.view setFrame:CGRectMake(0, 0, SCREEN_WIDTH, summaryViewHeight)];
//        [summaryVC.view setBackgroundColor:[UIColor colorWithPatternImage:[self imageCutter]]];
        summaryVC.view.opaque = NO;
        
        [self addChildViewController:summaryVC];

        return summaryVC.view;
    }else
        return nil;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (section == 0) {
        return 1;
    }else if(section == 1)
        
        return (self.maintableView.frame.size.height-summaryViewHeight)/rowHeight + 1;
    else
        return 10;
    
}




- (myMaskTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cellForRowAtIndexPath");
    if (indexPath.section == 0) {
        static NSString *CellIdentifier = @"Cell";
        
        myMaskTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[myMaskTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
        }
        
        return cell;
        
    }

    else
    {
        NSString *CellIdentifier = @"Cell1";
        
        myMaskTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[myMaskTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
            
        }
        [cell.category setText:@"吃喝 - 老铺烤鸭老铺烤鸭老铺烤鸭老铺烤鸭老铺烤鸭老铺烤鸭"];
        [cell.seperator setBackgroundColor:[UIColor purpleColor]];
        [cell.money setText:@"120"];
        
        return cell;
        
    }
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    for (myMaskTableViewCell *cell in self.maintableView.visibleCells) {
        CGFloat hiddenFrameHeight = scrollView.contentOffset.y + summaryViewHeight - cell.frame.origin.y;
        if (hiddenFrameHeight >= 0 || hiddenFrameHeight <= cell.frame.size.height) {
            [cell maskCellFromTop:hiddenFrameHeight];
        }
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView// called when scroll view grinds to a halt
{
    if (scrollView.contentOffset.y<moneyLuckSpace && scrollView.contentOffset.y>0.001) {
        [UIView animateWithDuration:0.35f animations:^(void){
            [scrollView setContentOffset:CGPointMake(0, moneyLuckSpace)];
        }];
    }else
        return;
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView.contentOffset.y<moneyLuckSpace && scrollView.contentOffset.y>0.001) {

        if (!decelerate) {
            [UIView animateWithDuration:0.35f animations:^(void){
                [scrollView setContentOffset:CGPointMake(0, moneyLuckSpace)];
            }];
        }else
            return;
        
    }else
        return;
}





- (IBAction)skinChange:(UIButton *)sender {
    NSLog(@"skinChange");
    if (sender.tag == 1) {
        self.gradientView.inputColor0 = [UIColor darkGrayColor];
        self.gradientView.inputColor1 = [UIColor blackColor];
        [sender setTitle:@"白" forState:UIControlStateNormal];
        [self.gradientView setNeedsDisplay];
        sender.tag = 10;

    }else
    {
        self.gradientView.inputColor0 = [UIColor colorWithRed:89/255.0f green:175/255.0f blue:185/255.0f alpha:1.0f];
        self.gradientView.inputColor1 = [UIColor colorWithRed:26/255.0f green:130/255.0f blue:195/255.0f alpha:1.0f];
        [sender setTitle:@"夜" forState:UIControlStateNormal];
        sender.tag = 1;

        [self.gradientView setNeedsDisplay];
    }

}

- (IBAction)menuTapped:(id)sender {
    [self.menuContainerViewController toggleRightSideMenuCompletion:^{
    
    }];
    
}

@end
