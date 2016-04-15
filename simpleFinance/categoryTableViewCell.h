//
//  categoryTableViewCell.h
//  simpleFinance
//
//  Created by Eric Cao on 4/15/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "categoryButton.h"

@protocol categoryTapDelegate <NSObject>

-(void)categoryTap:(UIButton *)sender;

@end

@interface categoryTableViewCell : UITableViewCell

@property (nonatomic,weak) id <categoryTapDelegate> categoryDelegate;
@property(nonatomic,strong) categoryButton *firstButton;
-(void)contentWithCategories:(NSArray *)cateArray;

@end
