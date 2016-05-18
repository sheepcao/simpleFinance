//
//  trendTableViewCell.m
//  simpleFinance
//
//  Created by Eric Cao on 4/27/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "trendTableViewCell.h"
#import "global.h"
#import "CommonUtility.h"

#define  pointRadius 8


@implementation trendTableViewCell
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
//        CGFloat thisRowHeight = self.frame.size.height;
        
        self.seperator = [[UIImageView alloc] initWithFrame:CGRectMake(18, SCREEN_WIDTH/10/2-pointRadius, pointRadius*2, pointRadius*2)];
        self.seperator.backgroundColor = [UIColor colorWithRed:242/255.0f green:191/255.0f blue:109/255.0f alpha:1.0f];
        [self.seperator setImage:[UIImage imageNamed:@"done"]];
        self.seperator.layer.cornerRadius = pointRadius;
//        self.seperator.layer.masksToBounds = YES;
        self.seperator.layer.shadowColor = [UIColor colorWithRed:.23 green:.23 blue:.23 alpha:1.0f].CGColor;
        self.seperator.layer.shadowOpacity = 1.0;
        self.seperator.layer.shadowRadius = 1.5f;
        self.seperator.layer.shadowOffset = CGSizeMake(1.0f, 2.5f);
        
        
        self.category = [[UILabel alloc] initWithFrame:CGRectMake(self.seperator.frame.size.width+self.seperator.frame.origin.x+10, 3, (SCREEN_WIDTH-60 - pointRadius - 80), SCREEN_WIDTH/10-3*2)];
        self.money = [[UIButton alloc] initWithFrame:CGRectMake(self.category.frame.origin.x+self.category.frame.size.width, 2, 80, SCREEN_WIDTH/10 - 4)];
        self.category.textAlignment = NSTextAlignmentLeft;
        self.money.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        self.money.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 5);
        self.money.layer.cornerRadius = 5.0f;

        UIFontDescriptor *attributeFontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                                     @{UIFontDescriptorFamilyAttribute: @"Helvetica Neue",
                                                       UIFontDescriptorNameAttribute:@"HelveticaNeue-Medium",
                                                       UIFontDescriptorSizeAttribute: [NSNumber numberWithFloat: SCREEN_WIDTH/19]
                                                       }];
        UIFontDescriptor *attributeFontDescriptorFirstPart = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                                              @{UIFontDescriptorFamilyAttribute: @"Source Han Sans CN",
                                                                UIFontDescriptorNameAttribute:@"SourceHanSansCN-Normal",
                                                                UIFontDescriptorSizeAttribute: [NSNumber numberWithFloat: SCREEN_WIDTH/21.5]
                                                                }];
        [self.money.titleLabel setFont:[UIFont fontWithDescriptor:attributeFontDescriptor size:0.0]];
        [self.money.titleLabel adjustsFontSizeToFitWidth];
        [self.category setFont:[UIFont fontWithDescriptor:attributeFontDescriptorFirstPart size:0.0]];
        
        self.category.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.48];
        self.category.shadowOffset =  CGSizeMake(0, 0.65);
        self.money.titleLabel.shadowColor = [normalColor colorWithAlphaComponent:0.35];
        self.money.titleLabel.shadowOffset =  CGSizeMake(0.16, 0.16);
        

        self.money.titleLabel.adjustsFontSizeToFitWidth = YES;
        
        [self addSubview:self.seperator];
        [self.seperator setHidden:YES];
        [self addSubview:self.category];
        [self addSubview:self.money];
        
        self.money.tag = 1;
    }
    return self;
}

-(void)makeTextColorForIncrease:(NSString *)increase
{
    
    
    if ([CommonUtility myContainsStringFrom:increase forSubstring:@"+"] ) {
        [self.money setBackgroundColor:[UIColor colorWithRed:211/255.0f green:65/255.0f blue:43/255.0f alpha:0.9f]];
        if ([increase integerValue] == 0 || ![increase integerValue] ) {
            [self.money setBackgroundColor:[UIColor colorWithRed:250/255.0f green:250/255.0f blue:250/255.0f alpha:0.1f]];
        }

    }else if([CommonUtility myContainsStringFrom:increase forSubstring:@"-"])
    {
        [self.money setBackgroundColor:[UIColor colorWithRed:72/255.0f green:210/255.0f blue:86/255.0f alpha:0.9f]];
    }else
    {
        [self.money setBackgroundColor:[UIColor colorWithRed:250/255.0f green:250/255.0f blue:250/255.0f alpha:0.1f]];
    }
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
