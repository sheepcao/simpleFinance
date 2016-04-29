//
//  addNewItemViewController.h
//  simpleFinance
//
//  Created by Eric Cao on 4/12/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol reloadDataDelegate <NSObject>

-(void)refreshData;
@end


@interface addNewItemViewController : UIViewController

@property (nonatomic,weak)  id <reloadDataDelegate> refreshDelegate;

@property BOOL isEditing;
@property NSInteger isEditingIncome;
@property (nonatomic,strong) NSString *editingMoney;
@property (nonatomic,strong) NSString *editingNote;
@property (nonatomic,strong) NSString *editingCategory;
@property (nonatomic,strong) NSNumber *editingID;
@property (nonatomic ,strong) NSString *targetDate;


@end
