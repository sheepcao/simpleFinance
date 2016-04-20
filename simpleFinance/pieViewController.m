//
//  pieViewController.m
//  simpleFinance
//
//  Created by Eric Cao on 4/20/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "pieViewController.h"
#import "global.h"
#import "topBarView.h"
@interface pieViewController ()
@property (nonatomic ,strong) UISegmentedControl *moneyTypeSeg;

@end

@implementation pieViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self configTopbar];
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
    
  
    UIButton *saveButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 27, 60, 40)];
    saveButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    saveButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [saveButton setTitle:@"返回" forState:UIControlStateNormal];
    [saveButton setTitleColor:   [UIColor colorWithRed:76/255.0f green:101/255.0f blue:120/255.0f alpha:1.0f]forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
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
-(void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];

}
-(void)segmentAction:(UISegmentedControl *)Seg{
    NSInteger Index = Seg.selectedSegmentIndex;
    NSLog(@"Index %ld", Index);
    
}

@end
