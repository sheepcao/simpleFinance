//
//  trendTableViewCell.h
//  simpleFinance
//
//  Created by Eric Cao on 4/27/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface trendTableViewCell : UITableViewCell
@property (nonatomic,strong) UILabel *category;
@property (nonatomic,strong) UIButton *money;

@property (nonatomic,strong) UIView *seperator;

- (void)maskCellFromTop:(CGFloat)margin;
-(void)makeTextColorForIncrease:(NSString *)increase;
@end
