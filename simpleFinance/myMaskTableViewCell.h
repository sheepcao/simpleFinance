//
//  myMaskTableViewCell.h
//  simpleFinance
//
//  Created by Eric Cao on 4/8/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface myMaskTableViewCell : UITableViewCell

@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *money;

- (void)maskCellFromTop:(CGFloat)margin;
@end
