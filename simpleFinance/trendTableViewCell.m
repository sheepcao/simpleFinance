//
//  trendTableViewCell.m
//  simpleFinance
//
//  Created by Eric Cao on 4/27/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "trendTableViewCell.h"
#import "global.h"

@implementation trendTableViewCell


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        
        
        self.category = [[UILabel alloc] initWithFrame:CGRectMake(25, 3, (SCREEN_WIDTH-50)*2/3, SCREEN_WIDTH/8.5-3*2)];
        self.money = [[UILabel alloc] initWithFrame:CGRectMake(self.category.frame.origin.x+self.category.frame.size.width, 3, (SCREEN_WIDTH-50)/3, self.category.frame.size.height)];
        self.category.textAlignment = NSTextAlignmentLeft;
        self.money.textAlignment = NSTextAlignmentRight;
        
        //
        UIFontDescriptor *attributeFontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                                     @{UIFontDescriptorFamilyAttribute: @"Avenir Next",
                                                       UIFontDescriptorNameAttribute:@"AvenirNext-Medium",
                                                       UIFontDescriptorSizeAttribute: [NSNumber numberWithFloat: SCREEN_WIDTH/21]
                                                       }];
        UIFontDescriptor *attributeFontDescriptorFirstPart = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                                              @{UIFontDescriptorFamilyAttribute: @"Avenir Next",
                                                                UIFontDescriptorNameAttribute:@"AvenirNext-Regular",
                                                                UIFontDescriptorSizeAttribute: [NSNumber numberWithFloat: SCREEN_WIDTH/22]
                                                                }];
        [self.money setFont:[UIFont fontWithDescriptor:attributeFontDescriptor size:0.0]];
        [self.category setFont:[UIFont fontWithDescriptor:attributeFontDescriptorFirstPart size:0.0]];

        self.category.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.48];
        self.category.shadowOffset =  CGSizeMake(0, 0.65);
        self.money.shadowColor = [TextColor colorWithAlphaComponent:0.35];
        self.money.shadowOffset =  CGSizeMake(0.16, 0.16);
        
        self.category.textColor = TextColor;
        self.money.textColor = TextColor;
        self.money.adjustsFontSizeToFitWidth = YES;
        
        
        [self addSubview:self.category];
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
