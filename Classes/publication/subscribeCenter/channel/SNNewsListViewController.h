//
//  SNNewsListViewController.h
//  sohunews
//
//  Created by wang yanchen on 13-4-15.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNRollingNewsTableController.h"

@interface SNNewsListViewController : SNRollingNewsTableController <SNActionSheetDelegate>

// for reset tableview`s frame
- (void)finishChangeTableviewFrame;

@end
