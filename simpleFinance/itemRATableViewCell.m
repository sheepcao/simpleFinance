//
//  itemRATableViewCell.m
//  simpleFinance
//
//  Created by Eric Cao on 5/5/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "itemRATableViewCell.h"
#import "CommonUtility.h"

@implementation itemRATableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupWithCategory:(NSString *)category andDescription:(NSString *)description andIncome:(NSString *)income andExpense:(NSString *)expense andColor:(UIColor *)myColor
{
    self.point.layer.cornerRadius = self.point.frame.size.width/2;
    self.point.layer.masksToBounds = YES;
    
    if (!description || [description isEqualToString:@""]) {
        self.categoryLabel.text = category;
    }else
    {
        NSString *itemDetail = [NSString stringWithFormat:@"%@ - %@",category,description];
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:itemDetail];
        UIFontDescriptor *attributeFontDescriptorFirstPart = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                                              @{UIFontDescriptorFamilyAttribute: @"Helvetica Neue",
                                                                UIFontDescriptorNameAttribute:@"HelveticaNeue-Medium",
                                                                UIFontDescriptorSizeAttribute: [NSNumber numberWithFloat: 14]
                                                                }];
        
        
        UIFontDescriptor *attributeFontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                                     @{UIFontDescriptorFamilyAttribute: @"Source Han Sans CN",
                                                       UIFontDescriptorNameAttribute:@"SourceHanSansCN-Normal",
                                                       UIFontDescriptorSizeAttribute: [NSNumber numberWithFloat: 12]
                                                       }];
        
        
        CGAffineTransform matrix =  CGAffineTransformMake(1, 0, tanf(8 * (CGFloat)M_PI / 180), 1, 0, 0);
        attributeFontDescriptor = [attributeFontDescriptor fontDescriptorWithMatrix:matrix];

        if([CommonUtility myContainsStringFrom:itemDetail forSubstring:@" - "])
        {
            
            NSRange range = [itemDetail rangeOfString:@" - "];
            NSRange rangeFirstPart,rangeSecondPart;
            rangeFirstPart.location = 0;
            rangeFirstPart.length = range.location;
            
            rangeSecondPart.location = range.location+range.length;
            rangeSecondPart.length = itemDetail.length -range.length - rangeFirstPart.length;
            
            [attributedText addAttribute:NSFontAttributeName value:[UIFont fontWithDescriptor:attributeFontDescriptor size:0] range:rangeSecondPart];
            [attributedText addAttribute:NSFontAttributeName value:[UIFont fontWithDescriptor:attributeFontDescriptorFirstPart size:0] range:rangeFirstPart];
            
//            [attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1.0f] range:rangeSecondPart];
        } else
        {
            [attributedText addAttribute:NSFontAttributeName value:[UIFont fontWithDescriptor:attributeFontDescriptorFirstPart size:0] range:NSMakeRange(0, attributedText.length)];
        }
        [attributedText addAttribute:NSForegroundColorAttributeName value:myColor range:NSMakeRange(0, attributedText.length)];

        self.categoryLabel.attributedText = attributedText;
    }
    
    NSString *money = @"";

    if ([income doubleValue] <0.001)
    {
        money = [NSString stringWithFormat:@"%.2f",(0 - [expense doubleValue])] ;
        [self.moneyLabel setTextColor:[UIColor colorWithRed:72/255.0f green:210/255.0f blue:86/255.0f alpha:1.0f]];
        
    }else
    {
        money =[NSString stringWithFormat:@"+%.2f",([income doubleValue])] ;
        [self.moneyLabel setTextColor:[UIColor colorWithRed:211/255.0f green:65/255.0f blue:43/255.0f alpha:1.0f]];
    }

    [self.moneyLabel setText:money];
    
    
    
    
    self.backgroundColor = [UIColor clearColor];
}

@end
