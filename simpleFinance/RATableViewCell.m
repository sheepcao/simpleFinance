
//The MIT License (MIT)
//
//Copyright (c) 2014 Rafał Augustyniak
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of
//this software and associated documentation files (the "Software"), to deal in
//the Software without restriction, including without limitation the rights to
//use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//the Software, and to permit persons to whom the Software is furnished to do so,
//subject to the following conditions:
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "RATableViewCell.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface RATableViewCell ()

//@property (weak, nonatomic) IBOutlet UILabel *detailedLabel;
@property (weak, nonatomic) IBOutlet UILabel *customTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *incomeLabel;
@property (weak, nonatomic) IBOutlet UILabel *expenseLabel;
@property (weak, nonatomic) IBOutlet UILabel *surplusLabel;
@property (weak, nonatomic) IBOutlet UIImageView *expandImage;
@property (weak, nonatomic) IBOutlet UILabel *incomeTitle;
@property (weak, nonatomic) IBOutlet UILabel *expenseTitle;
@property (weak, nonatomic) IBOutlet UILabel *surplusTitle;


@end

@implementation RATableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.selectedBackgroundView = [UIView new];
    self.selectedBackgroundView.backgroundColor = [UIColor clearColor];
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    gradientLayer.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithWhite:1.0 alpha:0.13].CGColor, (id)[UIColor colorWithWhite:1.0 alpha:0.012].CGColor, nil];
    
    gradientLayer.startPoint = CGPointMake(0.0f, 1.0f);
    gradientLayer.endPoint = CGPointMake(0.0f, 0.0f);
    self.layer.mask = gradientLayer;
    [self.layer insertSublayer:gradientLayer atIndex:0];
    
    [self.incomeTitle setText:NSLocalizedString(@"收入:",nil)];
    [self.expenseTitle setText:NSLocalizedString(@"支出:",nil)];
    [self.surplusTitle setText:NSLocalizedString(@"结余:",nil)];
    
    self.incomeTitle.adjustsFontSizeToFitWidth = YES;
    self.expenseTitle.adjustsFontSizeToFitWidth = YES;
    self.surplusTitle.adjustsFontSizeToFitWidth = YES;

    
}



- (void)setupWithTitle:(NSString *)title childCount:(NSInteger)childCount level:(NSInteger)level isExpanded:(BOOL)isExpanded  andIncome:(NSString *)income andExpense:(NSString *)expense andColor:(UIColor *)myColor
{

    [self.customTitleLabel setTextColor:myColor];
    [self.incomeLabel setTextColor:myColor];
    [self.expenseLabel setTextColor:myColor];
    [self.surplusLabel setTextColor:myColor];
    [self.incomeTitle setTextColor:myColor];
    [self.expenseTitle setTextColor:myColor];
    [self.surplusTitle setTextColor:myColor];


    
    
    self.customTitleLabel.text = title;
    self.expenseLabel.text = [NSString stringWithFormat:@"%@",expense];
    self.incomeLabel.text =  [NSString stringWithFormat:@"%@",income];;
    self.surplusLabel.text = [NSString stringWithFormat:@"%.2f", [income doubleValue] - [expense doubleValue]];

    
    if (isExpanded) {
        [self.expandImage setImage:[UIImage imageNamed:@"return"]];
    }else
    {
        [self.expandImage setImage:[UIImage imageNamed:@"expend"]];
    }
    
    if (childCount == 0) {
        [self.expandImage setImage:nil];
    }
    
    self.backgroundColor = [UIColor clearColor];
    
}


- (void)goExpendAnimated:(BOOL)animated
{
    [UIView animateWithDuration:animated ? 0.2 : 0 animations:^{
        [self.expandImage setImage:[UIImage imageNamed:@"return"]];
    }];
}
- (void)goCollapseAnimated:(BOOL)animated
{
    [UIView animateWithDuration:animated ? 0.2 : 0 animations:^{
        [self.expandImage setImage:[UIImage imageNamed:@"expend"]];
    }];
}

@end
