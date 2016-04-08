//
//  summeryViewController.m
//  simpleFinance
//
//  Created by Eric Cao on 4/7/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "summeryViewController.h"

@interface summeryViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *downLineHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *midLineHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *upLineHeight;


@end

@implementation summeryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
}
- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    [self.downLineHeight setConstant:0.6f];
    [self.midLineHeight setConstant:0.6f];
    [self.upLineHeight setConstant:0.6f];
    
    [self.view setNeedsUpdateConstraints];
    
    [self.view layoutIfNeeded];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)planMoney:(id)sender {
    NSLog(@"adasdasd");
}

@end
