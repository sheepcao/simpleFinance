//
//  categoryTableViewCell.m
//  simpleFinance
//
//  Created by Eric Cao on 4/15/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "categoryTableViewCell.h"
#import "global.h"
#define  symbolColor   [UIColor colorWithRed:196/255.0f green:178/255.0f blue:124/255.0f alpha:1.0f]


@implementation categoryTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        
        for (int i = 0; i< 4; i++) {
            categoryButton *categoryLabel = [[categoryButton alloc] initWithFrame:CGRectMake(20+i * ((SCREEN_WIDTH-20)/4), self.contentView.frame.size.height/2-15, (SCREEN_WIDTH-20)/4-20, (int)(SCREEN_WIDTH/13))];
            
            UIFontDescriptor *categoryFontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                                        @{UIFontDescriptorFamilyAttribute: @"Helvetica Neue",
                                                          UIFontDescriptorNameAttribute:@"HelveticaNeue",
                                                          UIFontDescriptorSizeAttribute: [NSNumber numberWithFloat: (int)(SCREEN_WIDTH/30)]
                                                          }];
            
            [categoryLabel.titleLabel setFont:[UIFont fontWithDescriptor:categoryFontDescriptor size:0.0]];
            [categoryLabel setTintColor:TextColor];
            categoryLabel.titleLabel.textAlignment = NSTextAlignmentCenter;
            categoryLabel.titleLabel.adjustsFontSizeToFitWidth = YES;
            categoryLabel.layer.borderWidth = 0.7f;
            categoryLabel.layer.borderColor = TextColor.CGColor;
            categoryLabel.layer.cornerRadius =(int)(SCREEN_WIDTH/65);
            categoryLabel.tag = i+1;
            
            [self.contentView addSubview:categoryLabel];
            
            if (i==0) {
                self.firstButton = categoryLabel;
            }
        }
    }
    
    return  self;
}

-(void)contentWithCategories:(NSArray *)cateArray
{
    for (int i = 0; i<cateArray.count; i++) {
        categoryButton *categoryLabel = (categoryButton *)[self viewWithTag:(i+1)];
        [categoryLabel addTarget:self.categoryDelegate action:@selector(categoryTap:) forControlEvents:UIControlEventTouchUpInside];

        [categoryLabel setTitle:[cateArray objectAtIndex:i] forState:UIControlStateNormal];
    }

}




@end
