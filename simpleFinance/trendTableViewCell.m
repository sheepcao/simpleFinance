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
//-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
//{
//    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
//    if (self)
//    {
//        CGFloat thisRowHeight = self.frame.size.height;
//        self.seperator = [[UIImageView alloc] initWithFrame:CGRectMake(18, thisRowHeight/2-pointRadius, pointRadius*2, pointRadius*2)];
//        self.seperator.backgroundColor = [UIColor blueColor];
//        self.seperator.layer.cornerRadius = pointRadius;
//        self.seperator.layer.masksToBounds = YES;
//
//        self.category = [[UILabel alloc] initWithFrame:CGRectMake(self.seperator.frame.size.width+self.seperator.frame.origin.x+10, 6, 100, thisRowHeight-6*2)];
//
//        self.MoneyRatio = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 95 , 7, 75, thisRowHeight-6*2)];
//        self.MoneyRatio.textAlignment = NSTextAlignmentRight;
//
//        UIView *midLine = [[UIView alloc] initWithFrame:CGRectMake(self.MoneyRatio.frame.origin.x - 5, thisRowHeight/2 - 8, 1, 16)];
//        midLine.backgroundColor = TextColor;
//
//
//
//        self.money = [[UILabel alloc] initWithFrame:CGRectMake(self.category.frame.origin.x+self.category.frame.size.width, 7, (SCREEN_WIDTH-(self.category.frame.origin.x+self.category.frame.size.width) - 95 - 9), thisRowHeight-6*2)];
//
//
//
//        //
//        UIFontDescriptor *attributeFontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:
//                                                     @{UIFontDescriptorFamilyAttribute: @"Avenir Next",
//                                                       UIFontDescriptorNameAttribute:@"AvenirNext-Medium",
//                                                       UIFontDescriptorSizeAttribute: [NSNumber numberWithFloat: SCREEN_WIDTH/25]
//                                                       }];
//        UIFontDescriptor *attributeFontDescriptorFirstPart = [UIFontDescriptor fontDescriptorWithFontAttributes:
//                                                              @{UIFontDescriptorFamilyAttribute: @"Avenir Next",
//                                                                UIFontDescriptorNameAttribute:@"AvenirNext-Regular",
//                                                                UIFontDescriptorSizeAttribute: [NSNumber numberWithFloat: SCREEN_WIDTH/22]
//                                                                }];
//        [self.money setFont:[UIFont fontWithDescriptor:attributeFontDescriptor size:0.0]];
//        [self.money adjustsFontSizeToFitWidth];
//
//        [self.MoneyRatio setFont:[UIFont fontWithDescriptor:attributeFontDescriptor size:0.0]];
//        [self.MoneyRatio adjustsFontSizeToFitWidth];
//
//        self.category.textAlignment = NSTextAlignmentLeft;
//        self.money.textAlignment = NSTextAlignmentRight;
//        self.MoneyRatio.textAlignment = NSTextAlignmentLeft;
//
//
//        [self.category setFont:[UIFont fontWithDescriptor:attributeFontDescriptorFirstPart size:0.0]];
//
//        self.category.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.48];
//        self.category.shadowOffset =  CGSizeMake(0, 0.65);
//        self.money.shadowColor = [TextColor colorWithAlphaComponent:0.35];
//        self.money.shadowOffset =  CGSizeMake(0.16, 0.16);
//        self.MoneyRatio.shadowColor = [TextColor colorWithAlphaComponent:0.35];
//        self.MoneyRatio.shadowOffset =  CGSizeMake(0.16, 0.16);
//
//        self.category.textColor = TextColor;
//        self.money.textColor = TextColor;
//        self.MoneyRatio.textColor = TextColor;
//
//
//        [self addSubview:self.category];
//        [self addSubview:self.seperator];
//        [self addSubview:self.money];
//        [self addSubview:midLine];
//        [self addSubview:self.MoneyRatio];
//
//    }
//    return self;
//}
//
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        CGFloat thisRowHeight = self.frame.size.height;
        
        self.seperator = [[UIImageView alloc] initWithFrame:CGRectMake(18, thisRowHeight/2-pointRadius, pointRadius*2, pointRadius*2)];
        self.seperator.backgroundColor = [UIColor blueColor];
        self.seperator.layer.cornerRadius = pointRadius;
        self.seperator.layer.masksToBounds = YES;
        
        
        self.category = [[UILabel alloc] initWithFrame:CGRectMake(self.seperator.frame.size.width+self.seperator.frame.origin.x+10, 3, (SCREEN_WIDTH-60 - pointRadius - 100), SCREEN_WIDTH/8.5-3*2)];
        self.money = [[UIButton alloc] initWithFrame:CGRectMake(self.category.frame.origin.x+self.category.frame.size.width, thisRowHeight/2 -15, 100, 30)];
        self.category.textAlignment = NSTextAlignmentLeft;
        self.money.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        self.money.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 5);
        self.money.layer.cornerRadius = 5.0f;
        

        //
        UIFontDescriptor *attributeFontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                                     @{UIFontDescriptorFamilyAttribute: @"Avenir Next",
                                                       UIFontDescriptorNameAttribute:@"AvenirNext-Medium",
                                                       UIFontDescriptorSizeAttribute: [NSNumber numberWithFloat: SCREEN_WIDTH/25]
                                                       }];
        UIFontDescriptor *attributeFontDescriptorFirstPart = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                                              @{UIFontDescriptorFamilyAttribute: @"Avenir Next",
                                                                UIFontDescriptorNameAttribute:@"AvenirNext-Regular",
                                                                UIFontDescriptorSizeAttribute: [NSNumber numberWithFloat: SCREEN_WIDTH/25]
                                                                }];
        [self.money.titleLabel setFont:[UIFont fontWithDescriptor:attributeFontDescriptor size:0.0]];
        [self.money.titleLabel adjustsFontSizeToFitWidth];
        [self.category setFont:[UIFont fontWithDescriptor:attributeFontDescriptorFirstPart size:0.0]];
        
        self.category.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.48];
        self.category.shadowOffset =  CGSizeMake(0, 0.65);
        self.money.titleLabel.shadowColor = [TextColor colorWithAlphaComponent:0.35];
        self.money.titleLabel.shadowOffset =  CGSizeMake(0.16, 0.16);
        
        self.category.textColor = TextColor;
        self.money.titleLabel.textColor = TextColor;
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
        [self.money setBackgroundColor:[UIColor colorWithRed:211/255.0f green:65/255.0f blue:43/255.0f alpha:1.0f]];

    }else if([CommonUtility myContainsStringFrom:increase forSubstring:@"-"])
    {
        [self.money setBackgroundColor:[UIColor colorWithRed:72/255.0f green:210/255.0f blue:86/255.0f alpha:1.0f]];
    }else
    {
        [self.money setBackgroundColor:[UIColor clearColor]];
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
