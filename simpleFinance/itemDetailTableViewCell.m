//
//  itemDetailTableViewCell.m
//  simpleFinance
//
//  Created by Eric Cao on 4/23/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "itemDetailTableViewCell.h"
#import "global.h"

@implementation itemDetailTableViewCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        CGFloat thisRowHeight = self.frame.size.height;
        
        self.leftText = [[UILabel alloc] initWithFrame:CGRectMake(25, 2, SCREEN_WIDTH/5, thisRowHeight - 4)];
        
        self.rightText = [[UILabel alloc] initWithFrame:CGRectMake(self.leftText.frame.origin.x + self.leftText.frame.size.width +30, 2, SCREEN_WIDTH*4/5 - 25-25 -30, thisRowHeight - 4)];
        [self addSubview:self.leftText ];
        [self addSubview:self.rightText ];
        
        self.leftText.font = [UIFont fontWithName:@"SourceHanSansCN-Normal" size:15.0f];
        self.leftText.textAlignment = NSTextAlignmentLeft;
        self.rightText.font = [UIFont fontWithName:@"SourceHanSansCN-Normal" size:14.0f];
        self.rightText.textAlignment = NSTextAlignmentRight;
        self.rightText.numberOfLines = 2;
        self.rightText.minimumScaleFactor = 0.8;
        
        [self.leftText setTextColor:TextColor];
        [self.rightText setTextColor:TextColor];

    }
    return self;
}



- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
