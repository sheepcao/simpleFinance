//
//  dayRATableViewCell.m
//  simpleFinance
//
//  Created by Eric Cao on 5/5/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "dayRATableViewCell.h"

@implementation dayRATableViewCell


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.selectedBackgroundView = [UIView new];
    self.selectedBackgroundView.backgroundColor = [UIColor clearColor];
    
}


- (void)setupWithTitle:(NSString *)title childCount:(NSInteger)childCount level:(NSInteger)level isExpanded:(BOOL)isExpanded
{
    self.customTitleLabel.text = title;
    
    self.backgroundColor = [UIColor clearColor];
    
    if (isExpanded) {
        [self.expandImage setImage:[UIImage imageNamed:@"minus1.png"]];
    }else
    {
        [self.expandImage setImage:[UIImage imageNamed:@"plus1.png"]];
    }
    

    if (childCount == 0) {
        [self.expandImage setImage:[UIImage imageNamed:@"equal1.png"]];
    }
    
}
- (void)goExpendAnimated:(BOOL)animated
{
    [UIView animateWithDuration:animated ? 0.2 : 0 animations:^{
        [self.expandImage setImage:[UIImage imageNamed:@"minus1.png"]];
    }];
}
- (void)goCollapseAnimated:(BOOL)animated
{
    [UIView animateWithDuration:animated ? 0.2 : 0 animations:^{
        [self.expandImage setImage:[UIImage imageNamed:@"plus1.png"]];
    }];
}

@end
