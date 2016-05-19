//
//  myMaskTableViewCell.m
//  simpleFinance
//
//  Created by Eric Cao on 4/8/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "myMaskTableViewCell.h"
#import "global.h"
#import "CommonUtility.h"

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
        
        self.category = [[UILabel alloc] initWithFrame:CGRectMake(self.seperator.frame.size.width+self.seperator.frame.origin.x+10, 6, (SCREEN_WIDTH-40-20-pointRadius*2)*3/5, rowHeight-6*2)];
        
        
        
        self.money = [[UILabel alloc] initWithFrame:CGRectMake(self.category.frame.origin.x+self.category.frame.size.width, 7, (SCREEN_WIDTH-6-20-pointRadius*2)*2/5, rowHeight-6*2)];
        self.category.textAlignment = NSTextAlignmentLeft;
        self.title.textAlignment = NSTextAlignmentLeft;
        self.money.textAlignment = NSTextAlignmentRight;

        
        
        if (IS_IPHONE_5_OR_LESS) {
            fontSize = 14.5f;
        }else if(IS_IPHONE_6)
        {
            fontSize = 15.0f;
        }else
        {
            fontSize = 16.5f;
        }
        
        //
                UIFontDescriptor *attributeFontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                                             @{UIFontDescriptorFamilyAttribute: @"Helvetica Neue",
                                                               UIFontDescriptorNameAttribute:@"HelveticaNeue-Medium",
                                                               UIFontDescriptorSizeAttribute: [NSNumber numberWithFloat: fontSize+1.6]
                                                               }];
        
        [self.money setFont:[UIFont fontWithDescriptor:attributeFontDescriptor size:0.0]];
        
        self.category.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.48];
        self.category.shadowOffset =  CGSizeMake(0, 0.65);
        self.money.shadowColor = [normalColor colorWithAlphaComponent:0.35];
        self.money.shadowOffset =  CGSizeMake(0.16, 0.16);
        

        [self addSubview:self.category];
        [self addSubview:self.seperator];
        [self addSubview:self.money];
    }
    return self;
}

-(void)makeTextStyle:(UIColor *)myColor
{
    
    self.category.textColor = myColor;
    self.title.textColor = myColor;
//    self.money.textColor = myColor;
    
    UIFontDescriptor *attributeFontDescriptorFirstPart = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                                          @{UIFontDescriptorFamilyAttribute: @"Helvetica Neue",
                                                            UIFontDescriptorNameAttribute:@"HelveticaNeue",
                                                   UIFontDescriptorSizeAttribute: [NSNumber numberWithFloat: fontSize]
                                                   }];

    
    UIFontDescriptor *attributeFontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                                 @{UIFontDescriptorFamilyAttribute: @"Source Han Sans CN",
                                                   UIFontDescriptorNameAttribute:@"SourceHanSansCN-Normal",
                                                   UIFontDescriptorSizeAttribute: [NSNumber numberWithFloat: fontSize-2.0]
                                                   }];
    
    
    CGAffineTransform matrix =  CGAffineTransformMake(1, 0, tanf(8 * (CGFloat)M_PI / 180), 1, 0, 0);
    attributeFontDescriptor = [attributeFontDescriptor fontDescriptorWithMatrix:matrix];
    
    
    NSString *srcText = self.category.text;
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:srcText];

    if([CommonUtility myContainsStringFrom:srcText forSubstring:@" - "])
    {
        NSRange range = [srcText rangeOfString:@" - "];
        NSRange rangeFirstPart,rangeSecondPart;
        rangeFirstPart.location = 0;
        rangeFirstPart.length = range.location;
        
        rangeSecondPart.location = range.location+range.length;
        rangeSecondPart.length = srcText.length -range.length - rangeFirstPart.length;
        
        [attributedText addAttribute:NSFontAttributeName value:[UIFont fontWithDescriptor:attributeFontDescriptor size:0] range:rangeSecondPart];
        [attributedText addAttribute:NSFontAttributeName value:[UIFont fontWithDescriptor:attributeFontDescriptorFirstPart size:0] range:rangeFirstPart];
        
//        [attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1.0f] range:rangeSecondPart];
    } else
    {
        [attributedText addAttribute:NSFontAttributeName value:[UIFont fontWithDescriptor:attributeFontDescriptorFirstPart size:0] range:NSMakeRange(0, attributedText.length)];
//        [attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1.0f] range:NSMakeRange(0, attributedText.length)];
    }
    self.category.attributedText = attributedText;
    
}

-(void)makeColor:(NSString *)category
{
    UIColor *seperatorColor = [[CommonUtility sharedCommonUtility] categoryColor:category];
    [self.seperator setBackgroundColor:seperatorColor];
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
