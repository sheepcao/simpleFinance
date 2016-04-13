//
//  numberPadButton.m
//  simpleFinance
//
//  Created by Eric Cao on 4/13/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "numberPadButton.h"
#define  symbolColor   [UIColor colorWithRed:196/255.0f green:178/255.0f blue:124/255.0f alpha:1.0f];
#define  symbolSelectedColor   [UIColor colorWithRed:120/255.0f green:101/255.0f blue:76/255.0f alpha:1.0f];

#define  numberColor   [UIColor colorWithRed:76/255.0f green:101/255.0f blue:120/255.0f alpha:1.0f];
#define  numberSelectedColor   [UIColor colorWithRed:124/255.0f green:167/255.0f blue:197/255.0f alpha:1.0f];

@interface numberPadButton ()
{
    CGRect selfFrame;
}


@end

@implementation numberPadButton

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        selfFrame = frame;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.backgroundColor = numberColor;
        self.layer.borderColor = [UIColor blackColor].CGColor;
        self.layer.borderWidth = 0.5f;

        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

        

    }
    return self;
}

- (void) setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    if (highlighted) {
        if (self.tag == 13) {
            return;
        }
        if ((self.tag==4) || (self.tag==8)  || (self.tag==12)  || (self.tag==16) ) {
            self.backgroundColor=symbolSelectedColor;
        }else
        {
            self.backgroundColor = numberSelectedColor;
        }
    }
    else {
        if (self.tag == 13) {
            return;
        }
        if ((self.tag==4) || (self.tag==8)  || (self.tag==12)  || (self.tag==16) ) {
            self.backgroundColor = symbolColor;
        }else
        {
            self.backgroundColor = numberColor;
        }
    }
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

//-(void)keySelectedStyle
//{
//    if ((self.tag==4) || (self.tag==8)  || (self.tag==12) || (self.tag==13) || (self.tag==16) ) {
//        [self setBackgroundColor:symbolSelectedColor];
//    }else
//    {
//        self.backgroundColor = numberSelectedColor;
//    }
//
//}
//
//-(void)keyNotSelectedStyle
//{
//    if ((self.tag==4) || (self.tag==8)  || (self.tag==12) || (self.tag==13) || (self.tag==16) ) {
//        self.backgroundColor = symbolColor;
//    }else
//    {
//        self.backgroundColor = numberColor;
//    }
//    
//}

-(void)setupNumbers
{
    switch (self.tag) {
        case 1:
            number = 7;
            break;
        case 2:
            number = 8;
            break;
        case 3:
            number = 9;
            break;
        case 5:
            number = 4;
            break;
        case 6:
            number = 5;
            break;
        case 7:
            number = 6;
            break;
        case 9:
            number = 1;
            break;
        case 10:
            number = 2;
            break;
        case 11:
            number = 3;
            break;
        case 14:
            number = 0;
            break;
        default:
            number = -1;

            break;
    }
}

-(void)setupSymbols
{
    fontSize = 36;
    fontType = @"HelveticaNeue-UltraLight";
    switch (self.tag) {
        case 1:
            self.symbolText = @"7";
            break;
        case 2:
            self.symbolText = @"8";
            break;
        case 3:
            self.symbolText = @"9";
            break;
        case 4:
            self.symbolText = @"*";
            fontType = @"HelveticaNeue";
            fontSize = 22;
            self.backgroundColor = symbolColor;
            [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [self setImage:[UIImage imageNamed:@"delete1.png"] forState:UIControlStateNormal];
            break;
        case 5:
            self.symbolText = @"4";
            break;
        case 6:
            self.symbolText = @"5";
            break;
        case 7:
            self.symbolText = @"6";
            break;
        case 8:
            self.symbolText = @"+";
            fontType = @"HelveticaNeue";
            fontSize = 22;
            self.backgroundColor = symbolColor;
            [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [self setImage:[UIImage imageNamed:@"plus1.png"] forState:UIControlStateNormal];

            break;
        case 9:
            self.symbolText = @"1";
            break;
        case 10:
            self.symbolText = @"2";
            break;
        case 11:
            self.symbolText = @"3";
            break;
        case 12:
            self.symbolText = @"-";
            fontType = @"HelveticaNeue";
            fontSize = 22;
            self.backgroundColor = symbolColor;
            [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [self setImage:[UIImage imageNamed:@"minus1.png"] forState:UIControlStateNormal];

            break;
        case 13:
    
            self.symbolText = @"备 注";
            fontType = @"HelveticaNeue-Light";
            fontSize = 16;
            self.layer.borderWidth = 1.0f;
            self.layer.borderColor = [UIColor darkGrayColor].CGColor;
            self.backgroundColor = [UIColor colorWithRed:152/255.0f green:154/255.0f blue:156/255.0f alpha:1.0f];
            [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

            break;
        case 14:
            self.symbolText = @"0";
            break;
        case 15:
            self.symbolText = @".";
            fontType = @"HelveticaNeue";
            fontSize = 22;
            break;
        case 16:
            self.symbolText = @"OK";
            fontType = @"HelveticaNeue";
            fontSize = 22;
            self.backgroundColor = symbolColor;
            [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [self setImage:[UIImage imageNamed:@"equal1.png"] forState:UIControlStateNormal];

            break;
            
        default:
            break;
    }
    

    
    UIFontDescriptor *attributeFontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                                 @{UIFontDescriptorFamilyAttribute: @"Helvetica Neue",
                                                   UIFontDescriptorNameAttribute:fontType,
                                                   UIFontDescriptorSizeAttribute: [NSNumber numberWithFloat: fontSize]
                                                   }];
    
    [self.titleLabel setFont:[UIFont fontWithDescriptor:attributeFontDescriptor size:0.0]];
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
