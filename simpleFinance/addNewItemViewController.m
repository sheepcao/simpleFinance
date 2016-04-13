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

@interface addNewItemViewController ()

@end

@implementation addNewItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    
    [self configTopbar];
    [self configNumberPad];
}

-(void)configTopbar
{
    topBarView *topbar = [[topBarView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)];
    topbar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:topbar];
    
    UIButton * closeViewButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-60, 26, 30, 30)];
    [closeViewButton setTitle:@"X" forState:UIControlStateNormal];
    [closeViewButton .titleLabel setFont:[UIFont boldSystemFontOfSize:20.0f]];
    [closeViewButton addTarget:self action:@selector(closeVC) forControlEvents:UIControlEventTouchUpInside];
    closeViewButton.backgroundColor = [UIColor clearColor];
    [topbar addSubview:closeViewButton];
}

-(void)configNumberPad
{
    UIView *numberPadView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - SCREEN_WIDTH*3/4, SCREEN_WIDTH, SCREEN_WIDTH*3/4)];
    numberPadView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:numberPadView];
}

-(void)closeVC
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
