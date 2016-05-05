//
//  historyViewController.h
//  simpleFinance
//
//  Created by Eric Cao on 4/26/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LGGradientBackgroundView/LGGradientBackgroundView.h"
#import "baseViewController.h"
@interface historyViewController : baseViewController

@property(nonatomic,strong) NSString *recordDate;
@property (strong, nonatomic) IBOutlet LGGradientBackgroundView *gradientView;
@end
