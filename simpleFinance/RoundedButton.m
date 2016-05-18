//
//  RoundedButton.m
//  simpleFinance
//
//  Created by Eric Cao on 4/12/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "RoundedButton.h"

@implementation RoundedButton

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.backgroundColor = [UIColor colorWithRed:223/255.0f green:162/255.0f blue:57/255.0f alpha:1.0f];
        self.layer.cornerRadius = frame.size.width/2;
        self.layer.masksToBounds = NO;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOpacity = 0.8;
        self.layer.shadowRadius = 2;
        self.layer.shadowOffset = CGSizeMake(0.0f, 1.5f);

        
}
    return self;
}

-(void)selectedStyle
{
    self.backgroundColor = [UIColor colorWithRed:229/255.0f green:182/255.0f blue:127/255.0f alpha:1.0f];
    self.layer.shadowRadius = 0;
    self.layer.shadowOffset = CGSizeMake(0.0f, 0.5f);
}
-(void)notSelectedStyle
{
    self.backgroundColor = [UIColor colorWithRed:223/255.0f green:162/255.0f blue:57/255.0f alpha:1.0f];
    self.layer.shadowRadius = 2;
    self.layer.shadowOffset = CGSizeMake(0.0f, 1.5f);
}



@end
