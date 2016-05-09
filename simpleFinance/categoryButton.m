//
//  categoryButton.m
//  simpleFinance
//
//  Created by Eric Cao on 4/15/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "categoryButton.h"
#import "global.h"

@implementation categoryButton

-(void)categorySelectedColor:(UIColor *)color
{
    self.layer.borderWidth = 1.2f;
    self.layer.borderColor = color.CGColor;
    
}

-(void)categoryNormalColor
{
    self.layer.borderWidth = 0.7f;
    self.layer.borderColor = TextColor.CGColor;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
