//
//  numberPadButton.h
//  simpleFinance
//
//  Created by Eric Cao on 4/13/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import <UIKit/UIKit.h>
#define  symbolColor   [UIColor colorWithRed:196/255.0f green:178/255.0f blue:124/255.0f alpha:1.0f]
#define  symbolSelectedColor   [UIColor colorWithRed:120/255.0f green:101/255.0f blue:76/255.0f alpha:1.0f]

#define  numberColor   [UIColor colorWithRed:76/255.0f green:101/255.0f blue:120/255.0f alpha:1.0f]
#define  numberSelectedColor   [UIColor colorWithRed:124/255.0f green:167/255.0f blue:197/255.0f alpha:1.0f]


@interface numberPadButton : UIButton
{
    int number;
    CGFloat fontSize;
    NSString *fontType;
}
@property (nonatomic,strong)NSString *symbolText;
@property (nonatomic,strong)UIView *selectedBack;
@property BOOL isNumber;


-(void)setupSymbols;
-(void)setupNumbers;
-(void)keySelectedStyle;
-(void)keyNotSelectedStyle;

@end
