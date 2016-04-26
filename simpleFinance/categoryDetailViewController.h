//
//  categoryDetailViewController.h
//  simpleFinance
//
//  Created by Eric Cao on 4/25/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface categoryDetailViewController : UIViewController

@property (nonatomic, strong) NSString *categoryName;
@property (nonatomic, strong) NSString *startDate;
@property (nonatomic, strong) NSString *endDate;
@property NSInteger categoryType;


@end
