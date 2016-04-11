//
//  ChartTableViewCell.m
//  simpleFinance
//
//  Created by Eric Cao on 4/11/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "ChartTableViewCell.h"
#import "PNChart.h"
@interface ChartTableViewCell()

@property (nonatomic, strong) PNPieChart *pieChart;
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
    
    self.pieChart = [[PNPieChart alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-120, 5.0, 240.0, 240.0) items:items];
    self.pieChart.descriptionTextColor = [UIColor whiteColor];
    self.pieChart.descriptionTextFont  = [UIFont fontWithName:@"Avenir-Medium" size:14.0];
    [self.pieChart strokeChart];
    self.pieChart.displayAnimated = NO;
    self.pieChart.shouldHighlightSectorOnTouch = NO;
    self.pieChart.labelPercentageCutoff = 0.1;
    [self addSubview:self.pieChart];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
