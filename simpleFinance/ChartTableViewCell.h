//
//  ChartTableViewCell.h
//  simpleFinance
//
//  Created by Eric Cao on 4/11/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChartTableViewCell : UITableViewCell

@property (nonatomic,strong) UIButton *centerButton;

-(void)drawPie;
-(void)updatePieWith:(NSArray *)array;
@end
