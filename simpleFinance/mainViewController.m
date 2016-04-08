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
#import "myMaskTableViewCell.h"


#define summaryViewHeight 136
#define bottomBar 50
#define rowHeight 40
#define topBarHeight 75



@interface mainViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>
{
    CGFloat moneyLuckSpace;
}

@end

@implementation mainViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    self.luckyText.alpha = 1.0f;
    
    self.maintableView = [[UITableView alloc] initWithFrame:CGRectMake(0, topBarHeight, SCREEN_WIDTH, SCREEN_HEIGHT- bottomBar -topBarHeight) style:UITableViewStylePlain];
    self.maintableView.showsVerticalScrollIndicator = NO;
    self.maintableView.backgroundColor = [UIColor clearColor];
    self.maintableView.delegate = self;
    self.maintableView.dataSource = self;
    self.maintableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.gradientView addSubview:self.maintableView];
    
    
    moneyLuckSpace = self.moneyLuckView.frame.size.height + self.moneyLuckView.frame.origin.y - topBarHeight;
    NSLog(@"moneyLuckSpace---:%f",moneyLuckSpace);
    
    [self.maintableView addObserver: self forKeyPath: @"contentOffset" options: NSKeyValueObservingOptionNew context: nil];

    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (self.maintableView.contentOffset.y > -0.0001 && self.maintableView.contentOffset.y - moneyLuckSpace/3 < 0.000001) {
        
        self.luckyText.alpha = 1.0 - self.maintableView.contentOffset.y/(moneyLuckSpace/4);
        
        
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
        return moneyLuckSpace;
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
//    else if (indexPath.section == 1) {
//        summeryTableViewCell *topCell =(summeryTableViewCell *) [tableView dequeueReusableCellWithIdentifier:@"summeryTableViewCell"];
//        if (nil == topCell)
//        {
//            topCell = [[[NSBundle mainBundle]loadNibNamed:@"summeryTableViewCell" owner:self options:nil] objectAtIndex:0];//加载nib文件
//            topCell.selectionStyle = UITableViewCellSelectionStyleNone;
//            
//            topCell.backgroundColor = [UIColor clearColor];
//            
//        }
//    
//        
//        return topCell;
//        
//    }
    else
    {
        NSString *CellIdentifier = @"Cell1";
        
        myMaskTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[myMaskTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
            
        }
        [cell.textLabel setText:@"123231231321"];
        
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


- (IBAction)skinChange:(id)sender {
    NSLog(@"skinChange");
    self.gradientView.inputColor0 = [UIColor darkGrayColor];
    self.gradientView.inputColor1 = [UIColor blackColor];
    [self.gradientView setNeedsDisplay];
}

//-(UIImage *)imageCutter
//{
//    UIGraphicsBeginImageContext(self.view.bounds.size);
//    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
//    UIImage *sourceImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    //now we will position the image, X/Y away from top left corner to get the portion we want
//    CGSize size = CGSizeMake(SCREEN_WIDTH, summaryViewHeight);
//    UIGraphicsBeginImageContext(size);
//    [sourceImage drawAtPoint:CGPointMake(0, 65)];
//    UIImage *croppedImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return croppedImage;
//}
@end
