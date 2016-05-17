//
//  PieExplainTableViewCell.m
//  simpleFinance
//
//  Created by Eric Cao on 4/20/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "PieExplainTableViewCell.h"
#import "global.h"
#define  pointRadius 8

@implementation PieExplainTableViewCell
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        if (IS_IPHONE_5_OR_LESS) {
            fontSize = 14.5f;
        }else if(IS_IPHONE_6)
        {
            fontSize = 15.0f;
        }else
        {
            fontSize = 15.5f;
        }
        
        CGFloat thisRowHeight = self.frame.size.height;
        self.seperator = [[UILabel alloc] initWithFrame:CGRectMake(25, thisRowHeight/2-pointRadius, pointRadius*2, pointRadius*2)];
        self.seperator.backgroundColor = [UIColor clearColor];
        self.seperator.layer.cornerRadius = pointRadius;
        self.seperator.layer.masksToBounds = YES;
        
        self.categoryName = [[UILabel alloc] initWithFrame:CGRectMake(self.seperator.frame.size.width+self.seperator.frame.origin.x+10, 6, 90, thisRowHeight-6*2)];
        
        self.MoneyRatio = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - fontSize*5.5 , 7, fontSize*4.52, thisRowHeight-6*2)];
        self.MoneyRatio.textAlignment = NSTextAlignmentLeft;
        self.MoneyRatio.adjustsFontSizeToFitWidth = YES;

        UIView *midline = [[UIView alloc] initWithFrame:CGRectMake(self.MoneyRatio.frame.origin.x - 9, self.MoneyRatio.frame.size.height/3, 1, self.MoneyRatio.frame.size.height*2/3)];
        [midline setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:midline];
        
        self.money = [[UILabel alloc] initWithFrame:CGRectMake(self.categoryName.frame.origin.x+self.categoryName.frame.size.width, 7, (midline.frame.origin.x - 8 -(self.categoryName.frame.origin.x+self.categoryName.frame.size.width) ), thisRowHeight-6*2)];
        self.categoryName.textAlignment = NSTextAlignmentLeft;
        self.money.textAlignment = NSTextAlignmentRight;
        self.money.adjustsFontSizeToFitWidth = YES;
        

        
        

        //
        UIFontDescriptor *attributeFontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                                     @{UIFontDescriptorFamilyAttribute: @"Helvetica Neue",
                                                       UIFontDescriptorNameAttribute:@"HelveticaNeue-Medium",
                                                       UIFontDescriptorSizeAttribute: [NSNumber numberWithFloat: fontSize+1.6]
                                                       }];
        
        [self.money setFont:[UIFont fontWithDescriptor:attributeFontDescriptor size:0.0]];
        [self.MoneyRatio setFont:[UIFont fontWithDescriptor:attributeFontDescriptor size:0.0]];

        self.categoryName.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.48];
        self.categoryName.shadowOffset =  CGSizeMake(0, 0.65);
        self.money.shadowColor = [normalColor colorWithAlphaComponent:0.35];
        self.money.shadowOffset =  CGSizeMake(0.16, 0.16);
        self.MoneyRatio.shadowColor = [normalColor colorWithAlphaComponent:0.35];
        self.MoneyRatio.shadowOffset =  CGSizeMake(0.16, 0.16);
        


        
        [self addSubview:self.categoryName];
        [self addSubview:self.seperator];
        [self addSubview:self.money];
        [self addSubview:self.MoneyRatio];

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
