//
//  myMaskTableViewCell.h
//  simpleFinance
//
//  Created by Eric Cao on 4/8/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface myMaskTableViewCell : UITableViewCell
{
    CGFloat fontSize;

}

@property (nonatomic,strong) UILabel *category;
@property (nonatomic,strong) UILabel *title;
@property (nonatomic,strong) UILabel *money;
@property (nonatomic,strong) UIView *seperator;


- (void)maskCellFromTop:(CGFloat)margin;
-(void)makeTextStyle:(UIColor *)myColor;
-(void)makeColor:(NSString *)category;
@end
