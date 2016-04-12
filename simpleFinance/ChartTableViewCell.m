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

//-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
//{
//    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
//
//    if (self) {
//        
//  
//    }
//    return self;
//   
//}

-(void)drawPie
{
    NSArray *items = @[[PNPieChartDataItem dataItemWithValue:80 color:PNRed
                            description:@"吃喝"],
                       [PNPieChartDataItem dataItemWithValue:20 color:PNBlue description:@"阅读"],
                       [PNPieChartDataItem dataItemWithValue:10 color:PNGreen description:@"一般消费"],
                       ];
    
    self.pieChart = [[PNPieChart alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-120, 15.0, 240.0, 240.0) items:items];
    self.pieChart.descriptionTextColor = [UIColor whiteColor];
    self.pieChart.descriptionTextFont  = [UIFont fontWithName:@"Avenir-Medium" size:14.0];
    [self.pieChart strokeChart];
    self.pieChart.displayAnimated = YES;
    self.pieChart.shouldHighlightSectorOnTouch = NO;
    self.pieChart.labelPercentageCutoff = 0.1;
    self.pieChart.duration = 0.65f;
    [self addSubview:self.pieChart];
    
    self.centerButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.pieChart.innerCircleRadius*2, self.pieChart.innerCircleRadius*2)];
    [self.centerButton setCenter:CGPointMake(self.pieChart.center.x, self.pieChart.center.y)];
    self.centerButton.layer.cornerRadius = self.centerButton.frame.size.width/2
    ;
    self.centerButton.layer.borderWidth = 0.8f;
    self.centerButton.layer.borderColor = [UIColor colorWithRed:0.88f green:0.88f blue:0.88f alpha:1.0f].CGColor;
    self.centerButton.backgroundColor = [UIColor clearColor];
    self.centerButton.titleLabel.numberOfLines = 2;
    [self.centerButton setTitleShadowColor: [[UIColor blackColor] colorWithAlphaComponent:0.48] forState:UIControlStateNormal] ;
    self.centerButton.titleLabel.shadowOffset =  CGSizeMake(0, 0.65);
    [self addSubview:self.centerButton];

    

}

-(void)switchCenterButtonToOutcome:(BOOL)isShowOutcome ByMoney:(NSString *)money
{
    NSMutableAttributedString* attrString;
    UIFontDescriptor *attributeFontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                              @{UIFontDescriptorFamilyAttribute: @"Source Han Sans CN",
                                                UIFontDescriptorNameAttribute:@"SourceHanSansCN-Normal",
                                                UIFontDescriptorSizeAttribute: [NSNumber numberWithFloat: 15.0f]
                                                }];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineSpacing:attributeFontDescriptor.pointSize *0.45];
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
                       value:TextColor
                       range:NSMakeRange(0, attrString.length)];
    [attrString addAttribute:NSShadowAttributeName
                       value:shadow
                       range:NSMakeRange(0, attrString.length)];
    
    
    self.centerButton.titleLabel.font = [UIFont fontWithDescriptor:attributeFontDescriptor size:0.0];


    [self.centerButton setAttributedTitle:attrString forState:UIControlStateNormal];


}

-(void)updatePieWith:(NSArray *)array
{
 
    [self.pieChart setItems:array];
    [self.pieChart recompute];
    [self.pieChart strokeChart];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
