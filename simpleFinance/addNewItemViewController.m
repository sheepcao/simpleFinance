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
#import "LGGradientBackgroundView/LGGradientBackgroundView.h"

#define topRowHeight 65

@interface addNewItemViewController ()
@property (nonatomic ,strong) UILabel *InputLabel;
@property (nonatomic ,strong) NSString *InputNumberString;
@property (nonatomic ,strong) NSString *NumberToOperate;
@property (nonatomic ,strong) numberPadButton *plusBtn;
@property (nonatomic ,strong) numberPadButton *minusBtn;
@property BOOL doingPlus;
@property BOOL doingMinus;


@end

@implementation addNewItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [self configTopbar];
    [self configInputArea];
    [self configNumberPad];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

-(void)configTopbar
{
    topBarView *topbar = [[topBarView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, topRowHeight)];
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

-(void)configInputArea
{
    //    UIView *rootView = [[[NSBundle mainBundle] loadNibNamed:@"inputNumberView" owner:self options:nil] objectAtIndex:0];
    self.InputLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, topRowHeight+5, SCREEN_WIDTH-30, SCREEN_WIDTH/4)];
    
    UIFontDescriptor *attributeFontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                                 @{UIFontDescriptorFamilyAttribute: @"Avenir Next",
                                                   UIFontDescriptorNameAttribute:@"AvenirNext-Ultralight",
                                                   UIFontDescriptorSizeAttribute: [NSNumber numberWithFloat: 35.0f]
                                                   }];
    
    [self.InputLabel setFont:[UIFont fontWithDescriptor:attributeFontDescriptor size:0.0]];
    self.InputLabel.textColor = TextColor;
    self.InputLabel.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:self.InputLabel];
    
    self.InputNumberString = @"";
    self.NumberToOperate = @"0.00";
    [self.InputLabel setText:@"0.00"];
    
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
            if (btn.tag == 8) {
                self.plusBtn = btn;
                self.doingPlus = NO;
            }else if(btn.tag ==12)
            {
                self.minusBtn =btn;
                self.doingMinus = NO;
            }
            [btn setTitle:[NSString stringWithFormat:@"%@",btn.symbolText] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(keyTapped:) forControlEvents:UIControlEventTouchUpInside];
            
            
        }
    }
}

-(void)keyTapped:(numberPadButton *)sender
{
    NSLog(@"%@",sender.symbolText);
    
    if (sender.isNumber ){
        
        if (!self.plusBtn.enabled || !self.minusBtn.enabled) {
            self.InputNumberString = @"";
            [self.InputLabel setText:@""];
            
            [self.plusBtn keyNotSelectedStyle];
            [self.minusBtn keyNotSelectedStyle];
        }
        
        
        NSString *intPart = [self.InputLabel .text componentsSeparatedByString:@"."][0];
        if (intPart.length>10) {
            return;
        }
        if (sender.tag == 15 && [self.InputNumberString rangeOfString:@"."].length != 0)  {
            /* represent " . " key*/
            return;
        }else
        {
            self.InputNumberString =  [self.InputNumberString stringByAppendingString:sender.symbolText];
            
            if ( [self.InputNumberString rangeOfString:@"."].length != 0)  {
                NSString *clean = [NSString stringWithFormat:@"%.2f", [self.InputNumberString doubleValue]];
                [self.InputLabel setText:clean];
            }else
            {
                NSString *clean = [NSString stringWithFormat:@"%lu", [self.InputNumberString integerValue]];
                [self.InputLabel setText:clean];
                
            }
        }
    }else
    {
        if(sender.tag == 4) // delete button
        {
            self.InputNumberString = self.InputLabel.text;
            if (self.InputNumberString.length == 0) {
                return;
            }else if (self.InputNumberString.length == 1) {
                self.InputNumberString = @"0";
            }else
            {
                self.InputNumberString = [self.InputNumberString substringToIndex:self.InputNumberString.length-1];
            }
            [self.InputLabel setText:self.InputNumberString];
        }
        
        if(sender.tag == 8) // ' + ' button
        {
            if (!self.minusBtn.enabled) {
                [self.minusBtn keyNotSelectedStyle];
                [sender keySelectedStyle];
                self.doingPlus = YES;
                self.doingMinus= NO;
                return;
            }
            
            if ([self.NumberToOperate doubleValue] > 0.0001 || [self.NumberToOperate doubleValue] < -0.0001) {
                
                if (self.doingPlus) {
                    double result = self.InputLabel.text.doubleValue + self.NumberToOperate.doubleValue;
                    NSString *resultText = [NSString stringWithFormat:@"%.2f",result];
                    if ([resultText rangeOfString:@".00"].length != 0) {
                        resultText = [resultText componentsSeparatedByString:@"."][0];
                    }
                    [self.InputLabel setText:resultText];
                }else if (self.doingMinus) {
                    double result = self.NumberToOperate.doubleValue - self.InputLabel.text.doubleValue;
                    if (result<0.0001) {
                        [self.InputLabel setText:@"0.00"];
                    }else
                    {
                        NSString *resultText = [NSString stringWithFormat:@"%.2f",result];
                        if ([resultText rangeOfString:@".00"].length != 0) {
                            resultText = [resultText componentsSeparatedByString:@"."][0];
                        }
                        [self.InputLabel setText:resultText];
                    }
                }
            }
            [sender keySelectedStyle];
            self.doingPlus = YES;
            self.doingMinus= NO;
            self.NumberToOperate = self.InputLabel.text;
            
        }
        
        if(sender.tag == 12) // ' - ' button
        {
            if (!self.plusBtn.enabled) {
                [self.plusBtn keyNotSelectedStyle];
                [sender keySelectedStyle];
                self.doingMinus = YES;
                self.doingPlus = NO;
                return;
            }
            
            if ([self.NumberToOperate doubleValue] > 0.0001 || [self.NumberToOperate doubleValue] < -0.0001) {
                
                if (self.doingPlus) {
                    double result = self.InputLabel.text.doubleValue + self.NumberToOperate.doubleValue;
                    NSString *resultText = [NSString stringWithFormat:@"%.2f",result];
                    if ([resultText rangeOfString:@".00"].length != 0) {
                        resultText = [resultText componentsSeparatedByString:@"."][0];
                    }
                    [self.InputLabel setText:resultText];
                }else if (self.doingMinus) {
                    double result = self.NumberToOperate.doubleValue - self.InputLabel.text.doubleValue;
                    if (result<0.0001) {
                        [self.InputLabel setText:@"0.00"];
                    }else
                    {
                        NSString *resultText = [NSString stringWithFormat:@"%.2f",result];
                        if ([resultText rangeOfString:@".00"].length != 0) {
                            resultText = [resultText componentsSeparatedByString:@"."][0];
                        }
                        [self.InputLabel setText:resultText];
                    }
                }
            }
            [sender keySelectedStyle];
            self.doingMinus = YES;
            self.doingPlus = NO;
            self.NumberToOperate = self.InputLabel.text;
            
        }
        
        if(sender.tag == 16)
        {
            if (!self.plusBtn.enabled || !self.minusBtn.enabled) {
                [self.plusBtn keyNotSelectedStyle];
                [self.minusBtn keyNotSelectedStyle];
                self.doingMinus = NO;
                self.doingPlus = NO;

            }
            
            if ([self.NumberToOperate doubleValue] > 0.0001 || [self.NumberToOperate doubleValue] < -0.0001) {
                
                if (self.doingPlus) {
                    double result = self.InputLabel.text.doubleValue + self.NumberToOperate.doubleValue;
                    NSString *resultText = [NSString stringWithFormat:@"%.2f",result];
                    if ([resultText rangeOfString:@".00"].length != 0) {
                        resultText = [resultText componentsSeparatedByString:@"."][0];
                    }
                    [self.InputLabel setText:resultText];
                }else if (self.doingMinus) {
                    double result = self.NumberToOperate.doubleValue - self.InputLabel.text.doubleValue;
                    if (result<0.0001) {
                        [self.InputLabel setText:@"0.00"];
                    }else
                    {
                        NSString *resultText = [NSString stringWithFormat:@"%.2f",result];
                        if ([resultText rangeOfString:@".00"].length != 0) {
                            resultText = [resultText componentsSeparatedByString:@"."][0];
                        }
                        [self.InputLabel setText:resultText];
                    }
                }else
                {
                    [self.InputLabel setText:self.NumberToOperate];
                }
                
                self.NumberToOperate = @"0.00";
            }
            
            if ([self.InputLabel.text isEqualToString:@"0.00"])
            {
                self.InputNumberString = @"";
            }else
            {
                self.InputNumberString = self.InputLabel.text;
            }

        }

        
        
        
    }
    
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
