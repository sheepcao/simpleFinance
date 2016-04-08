//
//  myMaskTableViewCell.m
//  simpleFinance
//
//  Created by Eric Cao on 4/8/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "myMaskTableViewCell.h"
#import "global.h"

#define  pointRadius 8

@implementation myMaskTableViewCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        
        self.seperator = [[UILabel alloc] initWithFrame:CGRectMake(20, rowHeight/2-pointRadius, pointRadius*2, pointRadius*2)];
        self.seperator.backgroundColor = [UIColor clearColor];
        self.seperator.layer.cornerRadius = pointRadius;
        self.seperator.layer.masksToBounds = YES;
        
        self.category = [[UILabel alloc] initWithFrame:CGRectMake(self.seperator.frame.size.width+self.seperator.frame.origin.x+10, 6, (SCREEN_WIDTH-40-20-pointRadius*2)*3/4, rowHeight-6*2)];

        

        self.money = [[UILabel alloc] initWithFrame:CGRectMake(self.category.frame.origin.x+self.category.frame.size.width, 6, (SCREEN_WIDTH-40-20-pointRadius*2)*1/4, rowHeight-6*2)];
        self.category.textAlignment = NSTextAlignmentLeft;
        self.title.textAlignment = NSTextAlignmentLeft;
        self.money.textAlignment = NSTextAlignmentRight;
        
        UIFontDescriptor *attributeFontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                                     @{UIFontDescriptorFamilyAttribute: @"Marion",
                                                       UIFontDescriptorNameAttribute:@"Marion-Light",
                                                       UIFontDescriptorSizeAttribute: @16.0
                                                                                        }];
        self.category.font = [UIFont fontWithDescriptor:attributeFontDescriptor size:0.0];
        [self.money setFont:[UIFont systemFontOfSize:16.0f weight:1.0f]];
        
        self.category.textColor = TextColor;
        self.title.textColor = TextColor;
        self.money.textColor = TextColor;
        
        [self addSubview:self.category];
        [self addSubview:self.seperator];
        [self addSubview:self.money];
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
