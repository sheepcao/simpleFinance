//
//  itemDetailViewController.h
//  simpleFinance
//
//  Created by Eric Cao on 4/23/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface itemDetailViewController : UIViewController
@property (nonatomic,strong) NSString *money;
@property (nonatomic,strong) NSString *category;
@property (nonatomic,strong) NSString *itemDescription;
@property (nonatomic,strong) NSString *itemCreatedTime;

@end
