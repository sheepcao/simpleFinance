//
//  global.h
//  simpleFinance
//
//  Created by Eric Cao on 4/7/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#ifndef global_h
#define global_h

#import "FMDatabase.h"

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 667.0)

#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)


#define PieHeight 270
#define summaryViewHeight 160
#define bottomBar 50
#define rowHeight 48
#define topBarHeight 75

#define categoryRowHeight 38

#define topRowHeight 65
#define categoryLabelWith 90
#define titleSize 19


#define  symbolColor   [UIColor colorWithRed:196/255.0f green:178/255.0f blue:124/255.0f alpha:1.0f]
#define  symbolSelectedColor   [UIColor colorWithRed:120/255.0f green:101/255.0f blue:76/255.0f alpha:1.0f]

#define  numberColor   [UIColor colorWithRed:76/255.0f green:101/255.0f blue:120/255.0f alpha:1.0f]
#define  numberSelectedColor   [UIColor colorWithRed:124/255.0f green:167/255.0f blue:197/255.0f alpha:1.0f]

#define TextColor [UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:1.0]

#define REVIEW_URL @"https://itunes.apple.com/cn/app/dota-quan-zi/id1028906602?ls=1&mt=8"

#define ALLAPP_URL @"itms://itunes.apple.com/us/artist/cao-guangxu/id844914783"

#define constellationService @"http://cgx.nwpu.info/simpleBuService/constellation.php"
#define backupService @"http://localhost/~ericcao/simpleBuService/uploads.php"
#define backupPath @"http://localhost/~ericcao/simpleBuService/upload/"

#define MODEL @"model"
#define AUTOSWITCH @"autoSwitch"
#define ThemeChanged  @"modelNotification"
#define LuckChanged  @"luckNotification"


#endif /* global_h */
