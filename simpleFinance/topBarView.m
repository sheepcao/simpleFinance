//
//  topBarView.m
//  simpleFinance
//
//  Created by Eric Cao on 4/13/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "topBarView.h"
#import "global.h"

@implementation topBarView

- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    
    // Draw them with a 2.0 stroke width so they are a bit more visible.
    CGContextSetLineWidth(context, 0.5f);
    
    CGContextMoveToPoint(context, 0.0f, rect.size.height-1.0); //start at this point
    
    CGContextAddLineToPoint(context, SCREEN_WIDTH, rect.size.height-1.0); //draw to this point
    
    // and now draw the Path!
    CGContextStrokePath(context);
}

@end
