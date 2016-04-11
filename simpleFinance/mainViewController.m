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
#import "ChartTableViewCell.h"






@interface mainViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>
{
    CGFloat moneyLuckSpace;
    CGFloat bottomHeight;
    CGFloat fontSize;
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

    [self configLuckyText];
    self.titleTextLabel.alpha = 1.0f;
    self.moneyBookText.alpha = 0.0f;
    
    self.navigationController.navigationBarHidden = YES;
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
    if (IS_IPHONE_5_OR_LESS) {
        moneyLuckSpace = moneyLuckSpace-40;
    }
    NSLog(@"moneyLuckSpace---:%f",moneyLuckSpace);
    
    [self.maintableView addObserver: self forKeyPath: @"contentOffset" options: NSKeyValueObservingOptionNew context: nil];

    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (self.maintableView.contentOffset.y > -0.0001 && self.maintableView.contentOffset.y - moneyLuckSpace*2/5 < 0.000001) {
        
        self.luckyText.alpha = 1.0 - self.maintableView.contentOffset.y/(moneyLuckSpace*2/5);
        self.titleTextLabel.alpha = 1.0 - self.maintableView.contentOffset.y/(moneyLuckSpace*2/5);
        self.moneyBookText.alpha = 0.0f;
        
    }else if (self.maintableView.contentOffset.y > -0.0001 && self.maintableView.contentOffset.y - moneyLuckSpace < 0.000001)
    {
        self.moneyBookText.alpha = self.maintableView.contentOffset.y/moneyLuckSpace;
        self.titleTextLabel.alpha = 0.0f;
        self.luckyText.alpha = 0.0f;


    }else if (self.maintableView.contentOffset.y < -0.00001)
    {
        [self.maintableView setContentOffset:CGPointMake(0, 0)];
    }
    
}

-(void)configLuckyText
{
    

    if (IS_IPHONE_5_OR_LESS) {
        fontSize = 12.5f;
    }else if(IS_IPHONE_6)
    {
        fontSize = 14.0f;
    }else
    {
        fontSize = 15.5f;
    }
    
    
    UIFontDescriptor *attributeFontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                                 @{UIFontDescriptorFamilyAttribute: @"Source Han Sans CN",
                                                   UIFontDescriptorNameAttribute:@"SourceHanSansCN-Normal",
                                                   UIFontDescriptorSizeAttribute: [NSNumber numberWithFloat: fontSize]
                                                   }];
    
    CGAffineTransform matrix =  CGAffineTransformMake(1, 0, tanf(12 * (CGFloat)M_PI / 180), 1, 0, 0);
    attributeFontDescriptor = [attributeFontDescriptor fontDescriptorWithMatrix:matrix];
    self.luckyText.font = [UIFont fontWithDescriptor:attributeFontDescriptor size:0.0];
    
    NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString:@"\t理财敏感度高，适合做长远布局，尤其是不用辛苦上班就可以有收益这类的被动收入，如房租、股权分红等等值得挖掘。适合做长远布局，尤其是不用辛苦上班就可以有收益这类的被动收入，如房租、股权分红等等值得挖掘"];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineSpacing:attributeFontDescriptor.pointSize *0.43];
    [attrString addAttribute:NSParagraphStyleAttributeName
                       value:style
                       range:NSMakeRange(0, attrString.length)];
    self.luckyText.attributedText = attrString;
    self.luckyText.numberOfLines = 6;
    self.luckyText.alpha = 1.0f;    
    self.luckyText.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.45];
    self.luckyText.shadowOffset =  CGSizeMake(0, 0.5);


//
//        for(NSString *fontfamilyname in [UIFont familyNames])
//        {
//            NSLog(@"family:'%@'",fontfamilyname);
//            for(NSString *fontName in [UIFont fontNamesForFamilyName:fontfamilyname])
//            {
//                NSLog(@"\tfont:'%@'",fontName);
//            }
//            NSLog(@"-------------");
//        }
//        NSLog(@"========%d Fonts",[UIFont familyNames].count);
//    
    
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
        return moneyLuckSpace;
    }else if(indexPath.section == 1 && indexPath.row == 9)
    {
        return 250;
    }
    else
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
    {
    
        return 10<((self.maintableView.frame.size.height-summaryViewHeight)/rowHeight)?((self.maintableView.frame.size.height-summaryViewHeight)/rowHeight)+1:10;
    }else
        return 10;
    
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
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

    else if(indexPath.section == 1 && indexPath.row == 9)
    {
        NSLog(@"row:%d",indexPath.row);
        NSString *CellIdentifier = @"CellBottom";
        
        ChartTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[ChartTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
            
        }
        
        [cell drawPie];
        
        
        return cell;
        
    }else
    {
        
        NSLog(@"row:%d",indexPath.row);
        NSString *CellIdentifier = @"Cell1";
        
        myMaskTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[myMaskTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
            
        }
       
        [cell.category setText:@"吃喝 - 老铺烤鸭"];
        [cell.seperator setBackgroundColor:[UIColor purpleColor]];
        [cell.money setText:@"120"];
        
        [cell makeTextStyle];
        
        return cell;
        
    }
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    for (UITableViewCell *cell in self.maintableView.visibleCells) {
        if ([cell isKindOfClass:[myMaskTableViewCell class]]) {
            myMaskTableViewCell *oneCell = (myMaskTableViewCell *)cell;
            CGFloat hiddenFrameHeight = scrollView.contentOffset.y + summaryViewHeight - cell.frame.origin.y;
            if (hiddenFrameHeight >= 0 || hiddenFrameHeight <= cell.frame.size.height) {
                [oneCell maskCellFromTop:hiddenFrameHeight];
            }
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
