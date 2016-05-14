//
//  ChartTableViewCell.h
//  simpleFinance
//
//  Created by Eric Cao on 4/11/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNChart.h"

@interface ChartTableViewCell : UITableViewCell

@property (nonatomic, strong) PNPieChart *pieChart;

@property (nonatomic,strong) UIButton *centerButton;

-(void)drawPieWithTextColor:(UIColor *)myColor;
-(void)updatePieWith:(NSArray *)array andColor:(UIColor *)myColor;
-(void)switchCenterButtonToOutcome:(BOOL)isShowOutcome ByMoney:(NSString *)money;
- (void)maskCellFromTop:(CGFloat)margin;

@end
