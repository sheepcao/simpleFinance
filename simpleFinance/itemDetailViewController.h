//
//  itemDetailViewController.h
//  simpleFinance
//
//  Created by Eric Cao on 4/23/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "baseViewController.h"

@interface itemDetailViewController : baseViewController

@property (nonatomic,strong) NSNumber *currentItemID;
@property (nonatomic,strong) NSString *money;
@property int itemType;
@property (nonatomic,strong) NSString *category;
@property (nonatomic,strong) NSString *categoryOnly;
@property (nonatomic,strong) NSString *itemDescription;
@property (nonatomic,strong) NSString *itemCreatedTime;

@end
