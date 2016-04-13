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
#import "numberPadButton.h"

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
    topBarView *topbar = [[topBarView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 65)];
    topbar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:topbar];
    
    UIButton * closeViewButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-65, 27, 60, 40)];
    closeViewButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    closeViewButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    [closeViewButton setTitle:@"取消" forState:UIControlStateNormal];
    [closeViewButton setTitleColor:   [UIColor colorWithRed:76/255.0f green:101/255.0f blue:120/255.0f alpha:1.0f]forState:UIControlStateNormal];
    [closeViewButton addTarget:self action:@selector(closeVC) forControlEvents:UIControlEventTouchUpInside];
    closeViewButton.backgroundColor = [UIColor clearColor];
    [topbar addSubview:closeViewButton];
    
//    UISegmentedControl *moneyTypeSeg = [[UISegmentedControl alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/4, 24, SCREEN_WIDTH/4, 40)];
    NSArray *segmentedArray = [[NSArray alloc]initWithObjects:@"支出",@"收入",nil];
    UISegmentedControl *moneyTypeSeg = [[UISegmentedControl alloc]initWithItems:segmentedArray];
    moneyTypeSeg.frame = CGRectMake(SCREEN_WIDTH*2/7, 30, SCREEN_WIDTH*3/7, 30);
    moneyTypeSeg.tintColor =  [UIColor colorWithRed:76/255.0f green:101/255.0f blue:120/255.0f alpha:1.0f];
    moneyTypeSeg.selectedSegmentIndex = 0;
    [topbar addSubview:moneyTypeSeg];
    
}

-(void)configNumberPad
{
    UIView *numberPadView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - SCREEN_WIDTH*7/10, SCREEN_WIDTH, SCREEN_WIDTH*7/10)];
    numberPadView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:numberPadView];
    
//    CGFloat buttonWidth = (numberPadView.frame.size.width-2)/4 - 1.2;
//    CGFloat buttonHeight = (numberPadView.frame.size.height-2)/4 - 1.2 ;
    CGFloat buttonWidth = (numberPadView.frame.size.width-2)/4 ;
    CGFloat buttonHeight = (numberPadView.frame.size.height-2)/4  ;
    
    for (int i = 0; i<4; i++) { // 4 coloum
        for (int j = 0; j<4; j++) {  // 4 row
            numberPadButton * btn = [[numberPadButton alloc] initWithFrame:CGRectMake(1+i * (buttonWidth), 1+j*(buttonHeight), buttonWidth, buttonHeight)];

            btn.tag = j*4+i+1;
            [btn setupSymbols];
            [numberPadView addSubview:btn];
            [btn setTitle:[NSString stringWithFormat:@"%@",btn.symbolText] forState:UIControlStateNormal];
//            
            [btn addTarget:self action:@selector(keyTapped:) forControlEvents:UIControlEventTouchUpInside];
//            //for button style on diff states.
//            [btn addTarget:self action:@selector(keyTapDown:) forControlEvents:UIControlEventTouchDown];
////            [btn addTarget:self action:@selector(KeyTapCancel:) forControlEvents:UIControlEventTouchCancel];
////            [btn addTarget:self action:@selector(KeyTapCancel:) forControlEvents:UIControlEventTouchDragExit];
////            [btn addTarget:self action:@selector(KeyTapCancel:) forControlEvents:UIControlEventTouchDragOutside];
//            [btn addTarget:self action:@selector(KeyTapCancel:) forControlEvents:UIControlEventTouchUpOutside];
//
//            
            
        }
    }
}

-(void)keyTapped:(numberPadButton *)sender
{
    NSLog(@"%@",sender.symbolText);
    
}
//-(void)keyTapDown:(numberPadButton *)sender
//{
//    [sender keySelectedStyle];
//    NSLog(@"%@",sender.symbolText);
//    
//}
//-(void)KeyTapCancel:(numberPadButton *)sender
//{
//    [sender keyNotSelectedStyle];
//    
//}

-(void)closeVC
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
