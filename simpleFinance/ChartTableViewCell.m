//
//  ChartTableViewCell.m
//  simpleFinance
//
//  Created by Eric Cao on 4/11/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "global.h"
#import "ChartTableViewCell.h"
@interface ChartTableViewCell()

@end

@implementation ChartTableViewCell


- (void)awakeFromNib {
    // Initialization code
    
}


-(void)drawPieWithTextColor:(UIColor *)myColor
{
    NSArray *items = @[[PNPieChartDataItem dataItemWithValue:80 color:PNRed
                                                 description:@"吃喝"],
                       [PNPieChartDataItem dataItemWithValue:20 color:PNBlue description:@"阅读"],
                       [PNPieChartDataItem dataItemWithValue:10 color:PNGreen description:@"一般消费"],
                       ];
    
    self.pieChart = [[PNPieChart alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-120, 15.0, 240.0, 240.0) items:items];
    self.pieChart.descriptionTextColor = myColor;
    self.pieChart.descriptionTextFont  = [UIFont fontWithName:@"Avenir-Medium" size:14.0];
    [self.pieChart strokeChart];
    self.pieChart.displayAnimated = YES;
    self.pieChart.shouldHighlightSectorOnTouch = NO;
    self.pieChart.userInteractionEnabled = NO;
    self.pieChart.labelPercentageCutoff = 0.05;
    self.pieChart.duration = 0.65f;
    [self addSubview:self.pieChart];
    
    self.centerButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.pieChart.innerCircleRadius*2, self.pieChart.innerCircleRadius*2)];
    [self.centerButton setCenter:CGPointMake(self.pieChart.center.x, self.pieChart.center.y)];    ;
    self.centerButton.layer.borderWidth = 1.0f;
    self.centerButton.layer.borderColor = [UIColor colorWithRed:0.88f green:0.88f blue:0.88f alpha:1.0f].CGColor;
    self.centerButton.backgroundColor = [UIColor colorWithRed:26/255.0f green:130/255.0f blue:194/255.0f alpha:1.0f];
    self.centerButton.titleLabel.numberOfLines = 2;
    
    self.centerButton.layer.cornerRadius = self.centerButton.frame.size.width/2;
    self.centerButton.layer.masksToBounds = NO;
    self.centerButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.centerButton.layer.shadowOpacity = 1.0;
    self.centerButton.layer.shadowRadius = 1.5f;
    self.centerButton.layer.shadowOffset = CGSizeMake(0.0f, 1.5f);
    self.centerButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 10, 0);
    
    self.centerButton.titleLabel.layer.shadowColor =  [UIColor blackColor].CGColor;
    self.centerButton.titleLabel.layer.shadowOffset = CGSizeMake(0.0f, 0.5f);
    
    
    UIImageView *switchImage= [[UIImageView alloc] initWithFrame:CGRectMake(self.centerButton.frame.size.width/3, self.centerButton.frame.size.height*3/4, self.centerButton.frame.size.width/3, self.centerButton.frame.size.height/6)];
    [switchImage setImage:[UIImage imageNamed:@"switchChart.png"]];
    //    switchImage.layer.shadowOffset = CGSizeMake(0.0f, 0.5f);
    
    [self.centerButton addSubview:switchImage];
    
    
    [self addSubview:self.centerButton];
    
    
    
}

-(void)switchCenterButtonToOutcome:(BOOL)isShowOutcome ByMoney:(NSString *)money
{
    NSMutableAttributedString* attrString;
    UIFontDescriptor *attributeFontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                                 @{UIFontDescriptorFamilyAttribute: @"Source Han Sans CN",
                                                   UIFontDescriptorNameAttribute:@"SourceHanSansCN-Normal",
                                                   UIFontDescriptorSizeAttribute: [NSNumber numberWithFloat:  self.centerButton.frame.size.width/4.8]
                                                   }];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineSpacing:attributeFontDescriptor.pointSize *0.41];
    style.alignment = NSTextAlignmentCenter;
    
    if (isShowOutcome) {
        attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"支 出\n%@",money]];
    }else
    {
        attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"收 入\n%@",money]];
    }
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.78];
    shadow.shadowBlurRadius = 0.0;
    shadow.shadowOffset = CGSizeMake(0.0, 1.0);
    
    [attrString addAttribute:NSParagraphStyleAttributeName
                       value:style
                       range:NSMakeRange(0, attrString.length)];
    [attrString addAttribute:NSForegroundColorAttributeName
                       value:normalColor
                       range:NSMakeRange(0, attrString.length)];
    [attrString addAttribute:NSShadowAttributeName
                       value:shadow
                       range:NSMakeRange(0, attrString.length)];
    
    
    self.centerButton.titleLabel.font = [UIFont fontWithDescriptor:attributeFontDescriptor size:0.0];
    
    
    [self.centerButton setAttributedTitle:attrString forState:UIControlStateNormal];
    
    
}

-(void)updatePieWith:(NSArray *)array andColor:(UIColor *)myColor
{
    
    [self.pieChart setItems:array];
    [self.pieChart recompute];
    [self.pieChart strokeChart];
    self.pieChart.descriptionTextColor = TextColor1;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


- (void)maskCellFromTop:(CGFloat)margin {
    self.layer.mask = [self visibilityMaskWithLocation:margin/self.frame.size.height];
    self.layer.masksToBounds = YES;
}

- (CAGradientLayer *)visibilityMaskWithLocation:(CGFloat)location {
    CAGradientLayer *mask = [CAGradientLayer layer];
    mask.frame = self.bounds;
    mask.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:1 alpha:0] CGColor], (id)[[UIColor colorWithWhite:1 alpha:1] CGColor], nil];
    mask.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:location], [NSNumber numberWithFloat:location], nil];
    return mask;
}

@end
